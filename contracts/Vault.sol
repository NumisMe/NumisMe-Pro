// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IManager.sol";
import "./interfaces/IController.sol";
import "./interfaces/IConverter.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IVaultToken.sol";
import "./interfaces/ExtendedIERC20.sol";

/**
 * @title Vault
 * @notice The vault is where users deposit and withdraw
 * like-kind assets that have been added by governance.
 */
contract Vault is IVault {
    using Address for address;
    using SafeERC20 for IERC20;

    uint256 public constant MAX = 10000;

    IManager public immutable override manager;
    mapping(address => bool) allowedToken;
    IVaultToken public immutable vaultToken;

    // Strategist-updated variables
    address public override gauge;
    uint256 public totalDepositCap;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event Earn(address indexed token, uint256 amount);

    /**
     * @param _depositToken The address of the deposit token of the vault
     * @param _vaultToken The address of the share token for the vault
     * @param _manager The address of the vault manager contract
     */
    constructor(
        address[] memory _depositToken,
        address _vaultToken,
        address _manager
    )
    {
        manager = IManager(_manager);
        vaultToken = IVaultToken(_vaultToken);
        totalDepositCap = 1e36;
        for(uint i=0; i<_depositToken.length; i++) {
            allowedToken[_depositToken[i]] = true;
        }
    }

    /**
     * STRATEGIST-ONLY FUNCTIONS
     */

    /**
     * @notice Sets the value of this vault's gauge
     * @dev Allow to be unset with the zero address
     * @param _gauge The address of the gauge
     */
    function setGauge(
        address _gauge
    )
        external
        notHalted
        onlyStrategist
    {
        gauge = _gauge;
    }

    /**
     * @notice Sets the value for the totalDepositCap
     * @dev totalDepositCap is the maximum amount of value that can be deposited
     * to the metavault at a time
     * @param _totalDepositCap The new totalDepositCap value
     */
    function setTotalDepositCap(
        uint256 _totalDepositCap
    )
        external
        notHalted
        onlyStrategist
    {
        totalDepositCap = _totalDepositCap;
    }

    /**
     * HARVESTER-ONLY FUNCTIONS
     */

    /**
     * @notice Sends accrued 3CRV tokens on the metavault to the controller to be deposited to strategies
     */
    function _earn(
        address _strategy,
        address _token
    )
        internal
        notHalted
        returns (uint256 _earned)
    {
        require(manager.allowedStrategies(_strategy), "!_strategy");
        IController _controller = IController(manager.controllers(address(this)));
        if (_controller.investEnabled()) {
            IERC20 token = IERC20(_token);
            uint256 _balance = token.balanceOf(address(this));
            token.safeTransfer(address(_controller), _balance);
            _earned = _controller.earn(_strategy, address(token), _balance);
        }
    }

    /**
     * USER-FACING FUNCTIONS
     */

    /**
     * @notice Deposits the given token into the vault
     * @param _token The token being deposited
     * @param _amount The amount of tokens to deposit
     * @param _strategy The strategy to deposit the tokens into
     * @param _harvestEstimates Output values for harvesting, should be inputted by frontend
     * @param _minSharesOutput Minimum shares an user will receive - needed when using converter
     */
    function deposit(
        address _token,
        uint256 _amount,
        address _strategy,
        uint256[] calldata _harvestEstimates,
        uint256 _minSharesOutput
    )
        public
        override
        notHalted
        returns (uint256 _shares)
    {
        require(allowedToken[_token], "Token not allowed");
        require(_amount > 0, "!_amount");
        
        IController _controller = IController(manager.controllers(address(this)));
        _controller.harvestStrategy(_strategy, _harvestEstimates);

        uint256 _balance = balance();
        IERC20 token = IERC20(_token);

        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        _amount = token.balanceOf(address(this)) - _before;
        uint256 _supply = IERC20(address(vaultToken)).totalSupply();

        _amount = _normalizeDecimals(_earn(_strategy, _token), _token);

        if (_supply > 0) {
            _amount = _amount*_supply/_balance;
        }

        _shares = _amount;
        require(_shares >= _minSharesOutput, "Receiving <min shares");

        require(_shares > 0, "shares=0");
        require(_supply + _shares <= totalDepositCap, ">totalDepositCap");
        vaultToken.mint(msg.sender, _shares);
        emit Deposit(msg.sender, _shares);
    }

    /**
     * @notice Withdraws an amount of shares to a given output token
     * @param _shares The amount of shares to withdraw
     * @param _token Output token
     * @param _minOutput Minimum output tokens to receive
     */
    function withdraw(
        uint256 _shares,
        address _token,
        uint256 _minOutput
    )
        public
        override
    {
        require(allowedToken[_token], "Token not allowed");
        IController _controller = IController(manager.controllers(address(this)));
        uint256 _amount = balance() * _shares / IERC20(address(vaultToken)).totalSupply();
        vaultToken.burn(msg.sender, _shares);
        IERC20 token = IERC20(_token);

        require(_controller.strategies() > 0, "No strategies to withdraw from");
        _controller.withdraw(address(token), _amount);

        require(token.balanceOf(address(this)) >= _minOutput, "Receiving <min");
        token.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice Withdraw the entire balance for an account
     * @param _token The address of the output token
     */
    function withdrawAll(address _token, uint256 _minOutput)
        external
        override
    {
        withdraw(IERC20(address(vaultToken)).balanceOf(msg.sender), _token, _minOutput);
    }

    /**
     * VIEWS
     */

    /**
     * @notice Returns the total balance of the vault, including strategies
     */
    function balance()
        public
        view
        override
        returns (uint256 _balance)
    {
        return _normalizeDecimals(IController(manager.controllers(address(this))).balanceOf(), address(0));
    }

    /**
     * @notice Returns the rate of vault shares
     */
    function getPricePerFullShare()
        external
        view
        override
        returns (uint256)
    {
        uint256 _supply = IERC20(address(vaultToken)).totalSupply();
        if (_supply > 0) {
            return balance() * 1e18 / _supply;
        } else {
            return balance();
        }
    }

    function getLPToken()
        external
        view
        override
        returns (address)
    {
        return address(vaultToken);
    }

    /**
     * @notice Returns the fee for withdrawing the given amount
     * @param _amount The amount to withdraw
     */
    function withdrawFee(
        uint256 _amount
    )
        external
        view
        override
        returns (uint256)
    {
        return manager.withdrawalProtectionFee() * _amount / MAX;
    }

    function _normalizeDecimals(
        uint256 _amount,
        address _token
    )
        internal
        view
        returns (uint256)
    {
        uint256 _decimals;
        if (_token == address(0)) {
            _decimals = 18;
        } else {
            _decimals = uint256(ExtendedIERC20(_token).decimals());
        } 
        if (_decimals < 18) {
            _amount = _amount * (10**(18-_decimals));
        }
        return _amount;
    }

    /**
     * MODIFIERS
     */

    modifier notHalted() {
        require(!manager.halted(), "halted");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == manager.strategist(), "!strategist");
        _;
    }
}

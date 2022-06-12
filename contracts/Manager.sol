// SPDX-License-Identifier: MIT
// solhint-disable max-states-count
// solhint-disable var-name-mixedcase

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IController.sol";
import "./interfaces/IManager.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IVault.sol";

/**
 * @title Manager
 * @notice This contract serves as the central point for governance-voted
 * variables. Fees and permissioned addresses are stored and referenced in
 * this contract only.
 */
contract Manager is IManager {

    uint256 public constant PENDING_STRATEGIST_TIMELOCK = 7 days;
    uint256 public constant MAX_TOKENS = 256;

    address public immutable override token;

    bool public override halted;

    address public override governance;
    address public override strategist;
    address public override pendingStrategist;
    address public override treasury;

    // The following fees are all mutable.
    // They are updated by governance (community vote).
    uint256 public override treasuryFee;
    uint256 public override withdrawalProtectionFee;


    uint256 private setPendingStrategistTime;

    // Governance must first allow the following properties before
    // the strategist can make use of them
    mapping(address => bool) public override allowedControllers;
    mapping(address => bool) public override allowedStrategies;
    mapping(address => bool) public override allowedVaults;

    // vault => controller
    mapping(address => address) public override controllers;

    event AllowedController(
        address indexed _controller,
        bool _allowed
    );
    event AllowedStrategy(
        address indexed _strategy,
        bool _allowed
    );
    event AllowedVault(
        address indexed _vault,
        bool _allowed
    );
    event Halted();
    event SetController(
        address indexed _vault,
        address indexed _controller
    );
    event SetGovernance(
        address indexed _governance
    );
    event SetPendingStrategist(
        address indexed _strategist
    );
    event SetStrategist(
        address indexed _strategist
    );

    /**
     * @param _token The address of the native token
     */
    constructor(
        address _token
    )
    {
        require(_token != address(0), "!_token");
        token = _token;
        governance = msg.sender;
        strategist = msg.sender;
        treasury = msg.sender;
        treasuryFee = 500;
        withdrawalProtectionFee = 10;
    }

    /**
     * GOVERNANCE-ONLY FUNCTIONS
     */

    /**
     * @notice Sets the permission for the given controller
     * @param _controller The address of the controller
     * @param _allowed The status of if it is allowed
     */
    function setAllowedController(
        address _controller,
        bool _allowed
    )
        external
        notHalted
        onlyGovernance
    {
        require(address(IController(_controller).manager()) == address(this), "!manager");
        allowedControllers[_controller] = _allowed;
        emit AllowedController(_controller, _allowed);
    }

    /**
     * @notice Sets the permission for the given strategy
     * @param _strategy The address of the strategy
     * @param _allowed The status of if it is allowed
     */
    function setAllowedStrategy(
        address _strategy,
        bool _allowed
    )
        external
        notHalted
        onlyGovernance
    {
        require(address(IStrategy(_strategy).manager()) == address(this), "!manager");
        allowedStrategies[_strategy] = _allowed;
        emit AllowedStrategy(_strategy, _allowed);
    }

    /**
     * @notice Sets the permission for the given vault
     * @param _vault The address of the vault
     * @param _allowed The status of if it is allowed
     */
    function setAllowedVault(
        address _vault,
        bool _allowed
    )
        external
        notHalted
        onlyGovernance
    {
        require(address(IVault(_vault).manager()) == address(this), "!manager");
        allowedVaults[_vault] = _allowed;
        emit AllowedVault(_vault, _allowed);
    }

    /**
     * @notice Sets the governance address
     * @param _governance The address of the governance
     */
    function setGovernance(
        address _governance
    )
        external
        notHalted
        onlyGovernance
    {
        governance = _governance;
        emit SetGovernance(_governance);
    }

    /**
     * @notice Sets the pending strategist and the timestamp
     * @param _strategist The address of the strategist
     */
    function setStrategist(
        address _strategist
    )
        external
        notHalted
        onlyGovernance
    {
        require(_strategist != address(0), "!_strategist");
        pendingStrategist = _strategist;
        // solhint-disable-next-line not-rely-on-time
        setPendingStrategistTime = block.timestamp;
        emit SetPendingStrategist(_strategist);
    }

    /**
     * @notice Sets the treasury address
     * @param _treasury The address of the treasury
     */
    function setTreasury(
        address _treasury
    )
        external
        notHalted
        onlyGovernance
    {
        require(_treasury != address(0), "!_treasury");
        treasury = _treasury;
    }

    /**
     * @notice Sets the treasury fee
     * @dev Throws if setting fee over 20%
     * @param _treasuryFee The value for the treasury fee
     */
    function setTreasuryFee(
        uint256 _treasuryFee
    )
        external
        notHalted
        onlyGovernance
    {
        require(_treasuryFee <= 5000, "_treasuryFee over 50%");
        treasuryFee = _treasuryFee;
    }

    /**
     * @notice Sets the withdrawal protection fee
     * @dev Throws if setting fee over 1%
     * @param _withdrawalProtectionFee The value for the withdrawal protection fee
     */
    function setWithdrawalProtectionFee(
        uint256 _withdrawalProtectionFee
    )
        external
        notHalted
        onlyGovernance
    {
        require(_withdrawalProtectionFee <= 100, "_withdrawalProtectionFee over 1%");
        withdrawalProtectionFee = _withdrawalProtectionFee;
    }

    /**
     * STRATEGIST-ONLY FUNCTIONS
     */

    /**
     * @notice Updates the strategist to the pending strategist
     * @dev This can only be called after the pending strategist timelock (7 days)
     */
    function acceptStrategist()
        external
        notHalted
    {
        require(msg.sender == pendingStrategist, "!pendingStrategist");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp > setPendingStrategistTime + PENDING_STRATEGIST_TIMELOCK, "PENDING_STRATEGIST_TIMELOCK");
        delete pendingStrategist;
        delete setPendingStrategistTime;
        strategist = msg.sender;
        emit SetStrategist(msg.sender);
    }

    /**
     * @notice Allows the strategist to pull tokens out of this contract
     * @dev This contract should never hold tokens
     * @param _token The address of the token
     * @param _amount The amount to withdraw
     * @param _to The address to send to
     */
    function recoverToken(
        IERC20 _token,
        uint256 _amount,
        address _to
    )
        external
        notHalted
        onlyStrategist
    {
        _token.transfer(_to, _amount);
    }

    /**
     * @notice Sets the vault address for a controller
     * @param _vault The address of the vault
     * @param _controller The address of the controller
     */
    function setController(
        address _vault,
        address _controller
    )
        external
        notHalted
        onlyStrategist
    {
        require(allowedVaults[_vault], "!_vault");
        require(allowedControllers[_controller], "!_controller");
        controllers[_vault] = _controller;
        emit SetController(_vault, _controller);
    }

    /**
     * @notice Sets the protocol as halted, disallowing all deposits forever
     * @dev Withdraws will still work, allowing users to exit the protocol
     */
    function setHalted()
        external
        notHalted
        onlyStrategist
    {
        halted = true;
        emit Halted();
    }

    /**
     * EXTERNAL VIEW FUNCTIONS
     */

    /**
     * @notice Returns a tuple of:
     *     YAXIS token address,
     *     Treasury address,
     *     Treasury fee
     */
    function getHarvestFeeInfo()
        external
        view
        override
        returns (
            address,
            address,
            uint256
        )
    {
        return (
            token,
            treasury,
            treasuryFee
        );
    }

    modifier notHalted() {
        require(!halted, "halted");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }
}

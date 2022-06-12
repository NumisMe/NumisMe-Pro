// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IGauge.sol";
import "../interfaces/ExtendedIERC20.sol";
import "./BaseStrategy.sol";

contract MockStrategyNative3Crv is BaseStrategy {
    // used for Crv -> weth -> [dai/usdc/usdt] -> 3crv route
    address public immutable crv;

    // for add_liquidity via curve.fi to get back 3CRV (use getMostPremium() for the best stable coin used in the route)
    address public immutable dai;
    address public immutable usdc;
    address public immutable usdt;

    address public immutable crvethPool;

    Mintr public immutable crvMintr;
    IStableSwap3Pool public immutable stableSwap3Pool;
    Gauge public immutable gauge; // 3Crv Gauge

    constructor(
        string memory _name,
        address _want,
        address _crvethPool,
        address _weth,
        Gauge _gauge,
        Mintr _crvMintr,
        IStableSwap3Pool _stableSwap3Pool,
        address _controller,
        address _manager,
        address[] memory _routerArray
    )
        BaseStrategy(_name, _controller, _manager, _want, _weth, _routerArray)
    {
        crv = ICurvePool(_crvethPool).coins(1);
        dai = ICurvePool(address(_stableSwap3Pool)).coins(0);
        usdc = ICurvePool(address(_stableSwap3Pool)).coins(1);
        usdt = ICurvePool(address(_stableSwap3Pool)).coins(2);
        stableSwap3Pool = _stableSwap3Pool;
        gauge = _gauge;
        crvMintr = _crvMintr;
        crvethPool = _crvethPool;
        IERC20(_want).approve(address(_gauge), type(uint256).max);
        IERC20(dai).approve(address(_stableSwap3Pool), type(uint256).max);
        IERC20(usdc).approve(address(_stableSwap3Pool), type(uint256).max);
        IERC20(usdt).approve(address(_stableSwap3Pool), type(uint256).max);
        IERC20(_want).approve(address(_stableSwap3Pool), type(uint256).max);
        IERC20(crv).approve(_crvethPool, type(uint256).max);
    }

    function _deposit()
        internal
        override
    {
        uint256 _wantBal = balanceOfWant();
        if (_wantBal > 0) {
            // deposit [want] to Gauge
            gauge.deposit(_wantBal);
        }
    }

    function _claimReward()
        internal
    {
        crvMintr.mint(address(gauge));
    }

    function _addLiquidity(uint256 _estimate)
        internal
    {
        uint256[3] memory amounts;
        amounts[0] = IERC20(dai).balanceOf(address(this));
        amounts[1] = IERC20(usdc).balanceOf(address(this));
        amounts[2] = IERC20(usdt).balanceOf(address(this));
        stableSwap3Pool.add_liquidity(amounts, _estimate);
    }

    function getMostPremium()
        public
        view
        returns (address, uint256)
    {
        uint daiBalance = stableSwap3Pool.balances(0);
        // USDC - Supports a change up to the 18 decimal standard
        uint usdcBalance = stableSwap3Pool.balances(1) * 1e18 / (10**(ExtendedIERC20(usdc).decimals()));
        uint usdtBalance = stableSwap3Pool.balances(2) * 1e12;

        if (daiBalance <= usdcBalance && daiBalance <= usdtBalance) {
            return (dai, 0);
        }

        if (usdcBalance <= daiBalance && usdcBalance <= usdtBalance) {
            return (usdc, 1);
        }

        if (usdtBalance <= daiBalance && usdtBalance <= usdcBalance) {
            return (usdt, 2);
        }

        return (dai, 0); // If they're somehow equal, we just want DAI
    }

    function _harvest(
        uint256[] calldata _estimates
    )
        internal
        override
    {
        _claimReward();

        uint256 _crvBalance = IERC20(crv).balanceOf(address(this));
        if (_crvBalance > 0) {
            _swapTokensCurve(crvethPool, 1, 0, _crvBalance, 1);
        }
        uint256 _remainingWeth = _payHarvestFees();
        if (_remainingWeth > 0) {
            (address _stableCoin,) = getMostPremium(); // stablecoin we want to convert to
            _swapTokens(weth, _stableCoin, _remainingWeth, 1);
            _addLiquidity(_estimates[0]);

            _deposit();
        }
    }

    function _withdrawAll()
        internal
        override
    {
        uint256 _bal = gauge.balanceOf(address(this));
        _withdraw(_bal);
    }

    function _withdraw(
        uint256 _amount
    )
        internal
        override
    {
        gauge.withdraw(_amount);
    }

    function balanceOfPool()
        public
        view
        override
        returns (uint256)
    {
        return gauge.balanceOf(address(this));
    }
}

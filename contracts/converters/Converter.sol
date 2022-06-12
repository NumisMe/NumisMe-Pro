// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IConverter.sol";
import "../interfaces/IManager.sol";
import "../interfaces/ICurve3Pool.sol";

contract StablesTo3CRV is IConverter {

    ICurve3Pool public immutable stableSwap3Pool;
    IERC20 public immutable token3CRV; // 3Crv

    IERC20 immutable public dai;
    IERC20 immutable public usdc;
    IERC20 immutable public usdt;

    /**
     * @param _tokenDAI The address of the DAI token
     * @param _tokenUSDC The address of the USDC token
     * @param _tokenUSDT The address of the USDT token
     * @param _token3CRV The address of the 3CRV token
     * @param _stableSwap3Pool The address of 3Pool
     */
    constructor(
        IERC20 _tokenDAI,
        IERC20 _tokenUSDC,
        IERC20 _tokenUSDT,
        IERC20 _token3CRV,
        ICurve3Pool _stableSwap3Pool
    )
    {
        dai = _tokenDAI;
        usdc = _tokenUSDC;
        usdt = _tokenUSDT;
        token3CRV = _token3CRV;
        stableSwap3Pool = _stableSwap3Pool;
        dai.approve(address(_stableSwap3Pool), type(uint256).max);
        usdc.approve(address(_stableSwap3Pool), type(uint256).max);
        usdt.approve(address(_stableSwap3Pool), type(uint256).max);
    }

    /**
     * @notice Allows to withdraw tokens from the converter
     * @dev This contract should never have any tokens in it at the end of a transaction
     * @param _token The address of the token
     * @param _to The address to receive the tokens
     */
    function recoverUnsupported(
        IERC20 _token,
        address _to
    )
        external
    {
        _token.transfer(_to, _token.balanceOf(address(this)));
    }

    /**
     * @notice Converts the all allowed input tokens to output token
     * @dev Output check should be added to msg.sender contract
     */
    function convert()
        external
        override
        returns (uint256 _outputAmount)
    {
        uint256[3] memory amounts;
        amounts[0] = dai.balanceOf(address(this));
        amounts[1] = usdc.balanceOf(address(this));
        amounts[2] = usdt.balanceOf(address(this));
        stableSwap3Pool.add_liquidity(amounts, 0);
        token3CRV.transfer(msg.sender, token3CRV.balanceOf(address(this)));
        return _outputAmount;
    }
}

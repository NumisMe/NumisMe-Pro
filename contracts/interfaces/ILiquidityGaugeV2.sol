// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILiquidityGaugeV2 {
    function set_approve_deposit(address, bool) external;
    function deposit(uint256) external;
    function withdraw(uint256) external;
}

// SPDX-License-Identifier: MIT
// solhint-disable func-name-mixedcase
// solhint-disable var-name-mixedcase

pragma solidity ^0.8.0;

interface IStableSwapPoolBTC {
    function coins(int128) external view returns (address);
    function get_virtual_price() external view returns (uint);
}

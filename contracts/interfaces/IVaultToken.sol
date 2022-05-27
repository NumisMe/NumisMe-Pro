// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IVaultToken {
    function mint(address,uint256) external;
    function burn(address,uint256) external;
}

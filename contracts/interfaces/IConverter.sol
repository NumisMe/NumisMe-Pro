// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IManager.sol";

interface IConverter {
    function convert() external returns (uint256 _outputAmount);
}

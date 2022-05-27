// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IManager.sol";

interface IConverter {
    function manager() external view returns (IManager);
    function convert(
    ) external returns (uint256 _outputAmount);
    function expected(
        address _input,
        address _output,
        uint256 _inputAmount
    ) external view returns (uint256 _outputAmount);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IManager.sol";

interface IController {
    function balanceOf() external view returns (uint256);
    function earn(address _strategy, address _token, uint256 _amount) external returns (uint256);
    function investEnabled() external view returns (bool);
    function harvestStrategy(address _strategy, uint256[] calldata _estimates) external;
    function manager() external view returns (IManager);
    function strategies() external view returns (uint256);
    function withdraw(address _token, uint256 _amount) external;
    function withdrawAll(address _strategy, address _convert) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IManager {
    function allowedControllers(address) external view returns (bool);
    function allowedStrategies(address) external view returns (bool);
    function allowedVaults(address) external view returns (bool);
    function controllers(address) external view returns (address);
    function getHarvestFeeInfo() external view returns (address, address, uint256);
    function governance() external view returns (address);
    function halted() external view returns (bool);
    function pendingStrategist() external view returns (address);
    function strategist() external view returns (address);
    function treasury() external view returns (address);
    function treasuryFee() external view returns (uint256);
    function withdrawalProtectionFee() external view returns (uint256);
    function token() external view returns (address);
}

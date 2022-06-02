// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IManager.sol";

interface IVault {
    function balance() external view returns (uint256);
    function deposit(address _token, uint256 _amount, address _strategy, uint256[] calldata _harvestEstimates, uint256 _minSharesOutput) external returns (uint256);
    function gauge() external returns (address);
    function getLPToken() external view returns (address);
    function getPricePerFullShare() external view returns (uint256);
    function manager() external view returns (IManager);
    function withdraw(uint256, address, uint256) external;
    function withdrawAll(address, uint256) external;
    function withdrawFee(uint256 _amount) external view returns (uint256);
}

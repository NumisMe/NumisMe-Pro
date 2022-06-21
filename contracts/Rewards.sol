// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function mint(address, uint256) external;
}

contract Rewards is Ownable {

    IERC20 public immutable reward;
    IERC20 public immutable lp;

    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public userPaid;

    uint256 public totalStaked; // Total amount of lp staked
    uint256 public accRewardsPerLP; // Accumulated rewards per staked LP
    uint256 public emission; // Token being emitted per second
    uint256 public lastUpdate; // Last time updatePool() was called

    uint256 public totalClaimed;
    uint256 public totalEmitted;

    constructor(address _lp, address _reward) {
        lp = IERC20(_lp);
        reward = IERC20(_reward);
    }

    function deposit(uint256 amount) external {
        address user = msg.sender;
        _claim(user);
        lp.transferFrom(user, address(this), amount);
        userStaked[user] += amount;
        totalStaked += amount;
        userPaid[user] = accRewardsPerLP*userStaked[user]/1e18;
    }

    function withdraw(uint256 amount) external {
        address user = msg.sender;
        _claim(user);
        if (userStaked[user] < amount) amount = userStaked[user];
        userStaked[user] -= amount;
        totalStaked -= amount;
        lp.transfer(user, amount);
        userPaid[user] = accRewardsPerLP*userStaked[user]/1e18;
    }

    function claim() external {
        _claim(msg.sender);
    }

    function _claim(address user) private {
        updatePool();
        uint256 amount = (userStaked[user]*accRewardsPerLP/1e18)-userPaid[user];
        userPaid[user] += amount;
        reward.transfer(user, amount);
        totalClaimed += amount;
    }

    function updatePool() private {
        uint256 time = block.timestamp;
        if (totalStaked > 0) {
            uint256 totalEmission = emission*(time-lastUpdate);
            accRewardsPerLP += totalEmission*1e18/totalStaked;
            totalEmitted += totalEmission;
        }
        lastUpdate = time;
    }

    function shutdown() external onlyOwner {
        reward.transfer(admin, reward.balanceOf(address(this))-totalUnclaimed());
        updatePool();
        emission = 0;
    }

    function setEmission(uint256 _emission) external onlyOwner {
        updatePool();
        emission = _emission;
    }

    function pending(address user) external view returns (uint256) {
        if (totalStaked == 0) return 0;
        return (userStaked[user]*(accRewardsPerLP+(emission*(block.timestamp-lastUpdate)*1e18/totalStaked))/1e18)-userPaid[user];
    }

    function totalEmittedAndPending() public view returns (uint256) {
        return totalEmitted + emission*(block.timestamp-lastUpdate);
    }

    function totalUnclaimed() public view returns (uint256) {
        return totalEmittedAndPending() - totalClaimed;
    }
}
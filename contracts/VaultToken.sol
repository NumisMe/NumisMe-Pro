// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IManager.sol";
import "./interfaces/IVaultToken.sol";



contract VaultToken is IVaultToken, ERC20 {

    IManager public immutable manager;

    constructor(
        string memory _name,
        string memory _symbol,
        address _manager
    )
        ERC20(_name, _symbol)
    {
        manager = IManager(_manager);
    }

    function mint(
        address _account,
        uint256 _amount
    )
        external
        override
        onlyVault
    {
        _mint(_account, _amount);
    }

    function burn(
        address _account,
        uint256 _amount
    )
        external
        override
        onlyVault
    {
        _burn(_account, _amount);
    }

    // MODIFIERS

    modifier onlyVault() {
        require(manager.allowedVaults(msg.sender), "!vault");
        _;
    }
}

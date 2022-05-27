// SPDX-License-Identifier: MIT
// solhint-disable func-name-mixedcase
// solhint-disable var-name-mixedcase

pragma solidity ^0.8.0;

interface IStableSwapPool {
    function add_liquidity(address pool, uint[4] calldata amounts, uint min_mint_amount) external;
}

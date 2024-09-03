// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IUniswapAnchoredView {
    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external;
}

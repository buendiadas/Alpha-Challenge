// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IUniswapV1Pool {
   function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
   function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
   function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256 eth_bought);
   function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256 tokens_bought);
}
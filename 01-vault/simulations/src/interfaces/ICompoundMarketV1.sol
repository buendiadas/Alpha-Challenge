// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ICompoundMarketV1 {
    function supply(address _asset, uint256 _amount) external returns (uint256);
    function borrow(address _asset, uint256 _amount) external returns (uint256); 
}
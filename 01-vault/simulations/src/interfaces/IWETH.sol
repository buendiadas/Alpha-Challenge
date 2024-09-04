// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IWETH { 
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function balanceOf(address user) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
}
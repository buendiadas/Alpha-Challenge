// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


interface IERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
}
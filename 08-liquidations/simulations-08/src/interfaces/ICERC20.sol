// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IERC20.sol";

interface ICERC20 is IERC20 {
    function borrowBalanceCurrent(address account) external returns (uint256);

    function decimals() external view returns (uint8);

    function liquidateBorrow(address borrower, uint256 amount, address collateral) external returns (uint256);

    function mint(uint256) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function underlying() external returns (address);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ICompoundMarketV1} from "../src/interfaces/ICompoundMarketV1.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";

contract CompoundBorrow is Test {
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public sai = IERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    
    ICompoundMarketV1 public compoundMarket = ICompoundMarketV1(0x3FDA67f7583380E67ef93072294a7fAc882FD7E7); 
    address randomEOA = 0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5; // Random EOA
    address wethWhale = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;
    address saiWhale = 0xD9ebeBfDab08c643C5f2837632De920c70A56247;

    function setUp() public {
        vm.deal(wethWhale, 1 ether);
        vm.deal(randomEOA, 1000 ether);

        vm.startPrank(saiWhale);
        sai.transfer(randomEOA, 50000 ether);
        vm.startPrank(randomEOA);

        sai.approve(address(compoundMarket), type(uint256).max);
        compoundMarket.supply(address(sai), 10000 ether);
    }

    // Test borrowing on CompoundV1
    // This test will fail on June 5, 2019 (block 7896014), but it works previously to the deprecation of borrow
    // The deprecation details can be found here:  https://medium.com/compound-finance/compound-v1-deprecation-schedule-b345115575d9
   //  But it will work before the deprecation of the borrow function e.g block 7885014 (June 3, 2019)
    function testBorrow() public {
        uint256 borrowAmount = 1 ether; // Amount to borrow

        uint256 wethBalanceBefore = weth.balanceOf(randomEOA);

        // Borrow the asset
        compoundMarket.borrow(address(weth), borrowAmount);

        uint256 wethBalanceAfter = weth.balanceOf(randomEOA);

        // Check the borrowed balance
        uint256 borrowedBalance = wethBalanceAfter - wethBalanceBefore;
        console2.log("Borrowed balance: ", borrowedBalance);


        assertGt(borrowedBalance, 0, "Borrowed balance should be greater than 0");
    }
}
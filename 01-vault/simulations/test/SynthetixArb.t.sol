// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ICurvePool} from "../src/interfaces/ICurvePool.sol";
import {ISynthetixEtherWrapper} from "../src/interfaces/ISynthetixEtherWrapper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {Test, console2} from "forge-std/Test.sol";

contract StaleAmm is Test {
    IERC20 public seth = IERC20(0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb);
    IWETH public weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ICurvePool public curveEthSeth = ICurvePool(0xc5424B857f758E906013F3555Dad202e4bdB4567);
    ISynthetixEtherWrapper public synthetixWrapper = ISynthetixEtherWrapper(0xC1AAE9d18bBe386B102435a8632C8063d31e747C);
    address randomEOA = 0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5; // Random EOA
    address wethWhale = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;

    uint256 deadline = 1800000000; // Far in the futures


    function setUp() public {
        vm.deal(wethWhale, 1 ether);
        vm.deal(randomEOA, 10001 ether); // 1000 to do the trade and 1 for gas to be kept in the account

        vm.startPrank(randomEOA);

        weth.approve(address(curveEthSeth), type(uint256).max);
        seth.approve(address(curveEthSeth), type(uint256).max);

        weth.approve(address(synthetixWrapper), type(uint256).max);
        seth.approve(address(synthetixWrapper), type(uint256).max);

        weth.deposit{value: 10000 ether}();
    }
    
    // In this arbitrage we will get advantage of a premium on SETH
    // We will swap 100 WETH for SETH using the Synthetix Wrapper and then swap SETH for WETH on Curve
    function testArbitragePremium () public {

        uint256 maxMintableEth = synthetixWrapper.getReserves();

        console2.log("Max mintable eth: ", maxMintableEth);

        // 1st we will swap WETH for SETH using the Synthetix Wrapper
        uint256 wethBalanceBefore = weth.balanceOf(randomEOA);
        uint256 sethBalanceBefore = seth.balanceOf(randomEOA);
        uint256 ethBalanceBefore = address(randomEOA).balance;
        uint256 wrapperCapacityBefore =  synthetixWrapper.capacity();
        uint256 totalEthWethBefore = ethBalanceBefore + wethBalanceBefore;

        console2.log("eth balance before: ", ethBalanceBefore);
        console2.log("weth balance before mint: ", wethBalanceBefore);
        console2.log("seth balance before mint: ", sethBalanceBefore);
        console2.log("capacity balance before mint: ", wrapperCapacityBefore);
        console2.log("total eth + weth", totalEthWethBefore);
        synthetixWrapper.mint(10000 ether);

        uint256 wethBalanceAfterMint = weth.balanceOf(randomEOA);
        uint256 sethBalanceAfterMint = seth.balanceOf(randomEOA);
        uint256 ethBalanceAfterMint = address(randomEOA).balance;
        uint256 wrapperCapacityAfterMint =  synthetixWrapper.capacity();
        uint256 totalEthWethAfterMint = ethBalanceAfterMint + wethBalanceAfterMint;

        console2.log("eth balance after mint: ", ethBalanceAfterMint);
        console2.log("weth balance after mint / before curve exchange: ", wethBalanceAfterMint);
        console2.log("seth balance after mint / before curve exchane: ", sethBalanceAfterMint);
        console2.log("wrapper capacity after mint: ", wrapperCapacityAfterMint);
        console2.log("total eth + weth after mint", totalEthWethAfterMint);
        
        curveEthSeth.exchange(1, 0, sethBalanceAfterMint , sethBalanceAfterMint);


        uint256 wethBalanceAfterExchange = weth.balanceOf(randomEOA);
        uint256 sethBalanceAfterExchange = seth.balanceOf(randomEOA);
        uint256 ethBalanceAfterExchange = address(randomEOA).balance;
        uint256 totalEthWethAfterExchange = ethBalanceAfterExchange + wethBalanceAfterExchange;

        uint256 totalProfit = totalEthWethAfterExchange - totalEthWethBefore;


        console2.log("eth balance after exchange: ", ethBalanceAfterExchange);
        console2.log("weth balance after exchange: ", wethBalanceAfterExchange);
        console2.log("seth balance after exchange: ", sethBalanceAfterExchange);
        console2.log("total eth + weth after exchange", totalEthWethAfterExchange);

        console2.log("Total profit: ", totalProfit); 

        assertGt(totalProfit, 0, "Profit should be greater than 0");
    }
}
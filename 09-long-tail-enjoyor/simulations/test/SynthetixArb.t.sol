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

    uint256 deadline = 1800000000; // Far in the futures


    function setUp() public {
        vm.startPrank(randomEOA);

        weth.approve(address(curveEthSeth), type(uint256).max);
        seth.approve(address(curveEthSeth), type(uint256).max);

        weth.approve(address(synthetixWrapper), type(uint256).max);
        seth.approve(address(synthetixWrapper), type(uint256).max);
    }
    
    // In this arbitrage we will get advantage of a premium on SETH
    // We will swap 100 WETH for SETH using the Synthetix Wrapper and then swap SETH for WETH on Curve
    function testArbitragePremium () public {

        uint256 startingEthBalance = randomEOA.balance;
        console2.log("Starting ETH balance: ", startingEthBalance);
        

        //////////////////////////////////////////////////////////////
        // 1st we will simulate a flash loan of 10000 WETH          //
        //////////////////////////////////////////////////////////////
        uint256 maxEth  = synthetixWrapper.maxETH();
        
        uint256 loanAmount = maxEth;
        vm.deal(randomEOA, loanAmount);
 
        weth.deposit{value: loanAmount}();

        
        
        //////////////////////////////////////////////////////////////
        // 2nd we will swap WETH for SETH using the Synthetix Wrapper
        //////////////////////////////////////////////////////////////

        uint256 wethBalanceBefore = weth.balanceOf(randomEOA);
        uint256 sethBalanceBefore = seth.balanceOf(randomEOA);
        uint256 wrapperCapacityBefore =  synthetixWrapper.capacity();

        console2.log("weth balance before mint: ", wethBalanceBefore);
        console2.log("seth balance before mint: ", sethBalanceBefore);
        console2.log("capacity balance before mint: ", wrapperCapacityBefore);

        synthetixWrapper.mint(loanAmount);


        //////////////////////////////////////////////////////////////
        //         3rd we will swap SETH for WETH using Curve      //
        //////////////////////////////////////////////////////////////

        uint256 wethBalanceAfterMint = weth.balanceOf(randomEOA);
        uint256 sethBalanceAfterMint = seth.balanceOf(randomEOA);
        uint256 wrapperCapacityAfterMint =  synthetixWrapper.capacity();

        console2.log("weth balance after mint / before curve exchange: ", wethBalanceAfterMint);
        console2.log("seth balance after mint / before curve exchane: ", sethBalanceAfterMint);
        console2.log("wrapper capacity after mint: ", wrapperCapacityAfterMint);

        curveEthSeth.exchange(1, 0, sethBalanceAfterMint , sethBalanceAfterMint);

        uint256 wethBalanceAfterExchange = weth.balanceOf(randomEOA);
        uint256 sethBalanceAfterExchange = seth.balanceOf(randomEOA);
        uint256 ethBalanceAfterExchange = randomEOA.balance;
        
        console2.log("weth balance after after curve exchange: ", wethBalanceAfterExchange);
        console2.log("seth balance after curve exchane: ", sethBalanceAfterExchange);
        console2.log("wrapper capacity after exchange: ", wrapperCapacityAfterMint);
        console2.log("eth balance after exchange: ", ethBalanceAfterExchange);


        //////////////////////////////////////////////////////////////
        //         4th We repay the loan                           //
        //////////////////////////////////////////////////////////////
        

        weth.withdraw(weth.balanceOf(randomEOA));
        payable(address(0)).transfer(loanAmount);

        uint256 ethBalanceAfterRepay = randomEOA.balance;
        console2.log("eth balance after repay: ", ethBalanceAfterRepay);
        console2.log("seth balance after repay: ", sethBalanceAfterExchange);

        uint256 profit = ethBalanceAfterRepay - startingEthBalance;
        
        console2.log("Profit: ", profit);

        //assertGt(profit, 0);
    }
}
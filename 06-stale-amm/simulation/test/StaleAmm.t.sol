// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV1Pool} from "../src/interfaces/IUniswapV1Pool.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";

contract StaleAmm is Test {
    IUniswapV1Pool public uniswapV1Pool;
    IERC20 public tusdOld;
    IERC20 public tusdNew;

    address public mevContract = 0x0000000000007F150Bd6f54c40A34d7C3d5e9f56;
    address public tusdWhale = 0x75C007Def5Edf4175e892d60b0adF65D5dEe6a87;

    address randomEOA = 0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5; // Random EOA

    uint256 deadline = 1800000000; // Far in the futures


    function setUp() public {
        uniswapV1Pool = IUniswapV1Pool(0x4F30E682D0541eAC91748bd38A648d759261b8f3);
        tusdOld = IERC20(0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E);
        tusdNew = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);

        vm.deal(mevContract, 1 ether);
        vm.deal(tusdWhale, 1 ether);
        vm.deal(randomEOA, 1 ether);

        vm.startPrank(tusdWhale);

        console2.log("tusdWhale balance: ", tusdNew.balanceOf(tusdWhale));
        
        tusdNew.transfer(randomEOA, 10000 ether);

        vm.startPrank(randomEOA);
        tusdOld.approve(address(uniswapV1Pool), type(uint256).max);

        vm.startPrank(mevContract);
        tusdOld.approve(address(uniswapV1Pool), type(uint256).max);
    }
    

    //  Answer to 
    // b) Provide all necessary simulation data to arbitrage the pool on January 23, 2022.
    // @dev This test should use Block 14058541
    function testArbitrageJan232022 () public {
       address sender = randomEOA;
        
        uint256 ethBalancePoolBefore = address(uniswapV1Pool).balance;
        uint256 tusdBalancePoolOldBefore = tusdOld.balanceOf(address(uniswapV1Pool));
        uint256 tusdBalancePoolNewBefore = tusdNew.balanceOf(address(uniswapV1Pool));
        
        uint256 tusdBalanceSenderBefore = tusdOld.balanceOf(sender);
        uint256 ethBalanceSenderBefore = address(uniswapV1Pool).balance;

        uint256 estimatedOut = uniswapV1Pool.getEthToTokenInputPrice(0.1 ether);

        console2.log("contract eth balance before: ", ethBalancePoolBefore);
        console2.log("contract tusd balance old before: ", tusdBalancePoolOldBefore);
        console2.log("contract tusd balance new before: ", tusdBalancePoolNewBefore);

        console2.log("sender tusd balance before: ", tusdBalanceSenderBefore);
        console2.log("sender eth balance before: ", ethBalanceSenderBefore);

        console2.log("Estimated out: ", estimatedOut);

        // Call the tokenToEthSwapInput function

        uint256 actualOut = uniswapV1Pool.ethToTokenSwapInput{value: 0.1 ether}(1, deadline);

        uint256 estimatedOutAfter = uniswapV1Pool.getTokenToEthInputPrice(0.1 ether);

        uint256 ethBalanceContractAfter = address(uniswapV1Pool).balance;
        uint256 tusdBalanceContractOldAfter = tusdOld.balanceOf(address(uniswapV1Pool));
        uint256 tusdBalanceContractNewAfter = tusdNew.balanceOf(address(uniswapV1Pool));
        uint256 tusdBalanceSenderAfter = tusdOld.balanceOf(mevContract);
        uint256 ethBalanceSenderAfter = address(uniswapV1Pool).balance;


        console2.log("contract eth balance after: ", ethBalanceContractAfter);
        console2.log("contract tusd balance old after: ", tusdBalanceContractOldAfter);
        console2.log("contract tusd balance new after: ", tusdBalanceContractNewAfter);
        console2.log("sender tusd balance after: ", tusdBalanceSenderAfter);
        console2.log("sender eth balance after: ", ethBalanceSenderAfter);
        console2.log("estimatedOut after", estimatedOutAfter );
        console2.log("actual out: ", actualOut);
    }

    //    // Replicated transaction: https://etherscan.io/tx/0x3f1b5baef6ea7f622834eabe7634bf89e3f473b62a73e357fdd04a1a5cf32ecf
    // function testReplicateTransaction() public {
    //     // Replicate the same args used by the mev bot contract
    //     uint256 tokensSold = 188436139344589717503;
    //     uint256 minEth = 1;

    //     uint256 ethBalanceContractBefore = address(uniswapV1Pool).balance;
    //     uint256 tusdBalanceContractOldBefore = tusdOld.balanceOf(address(uniswapV1Pool));
    //     uint256 tusdBalanceContractNewBefore = tusdNew.balanceOf(address(uniswapV1Pool));
    //     uint256 tusdBalanceMevBefore = tusdOld.balanceOf(mevContract);
    //     uint256 tusdNewBalanceMevBefore = tusdNew.balanceOf(mevContract);
    //     uint256 ethBalanceMevBefore = address(uniswapV1Pool).balance;

    //     // Set the expected return value (this value can be for example taken from the logs)
    //     uint256 expectedOut = 189548469355043147;

    //     // Set the desired msg.sender (mev bot contract)
    //     address sender = mevContract;

    //     uint256 estimatedOut = uniswapV1Pool.getTokenToEthInputPrice(tokensSold);

    //     console2.log("pool eth balance before: ", ethBalanceContractBefore);
    //     console2.log("pool tusd balance old before: ", tusdBalanceContractOldBefore);
    //     console2.log("pool tusd balance new before: ", tusdBalanceContractNewBefore);
    //     console2.log("mev tusd balance before: ", tusdBalanceMevBefore);
    //     console2.log("mev tusd balance new before: ", tusdNewBalanceMevBefore);
    //     console2.log("mev eth balance before: ", ethBalanceMevBefore);

    //     console2.log("Empiric price: ", tokensSold * 1e18 / estimatedOut );
    //     console2.log("Estimated out: ", estimatedOut);

    //     // Call the tokenToEthSwapInput function

    //     uint256 actualOut = uniswapV1Pool.tokenToEthSwapInput(tokensSold, minEth, deadline);

    //     uint256 estimatedOutAfter = uniswapV1Pool.getTokenToEthInputPrice(tokensSold);

    //     uint256 ethBalanceContractAfter = address(uniswapV1Pool).balance;
    //     uint256 tusdBalanceContractOldAfter = tusdOld.balanceOf(address(uniswapV1Pool));
    //     uint256 tusdBalanceContractNewAfter = tusdNew.balanceOf(address(uniswapV1Pool));
    //     uint256 tusdBalanceMevAfter = tusdOld.balanceOf(mevContract);
    //     uint256 ethBalanceMevAfter = address(uniswapV1Pool).balance;

    //     console2.log("pool eth balance after: ", ethBalanceContractAfter);
    //     console2.log("pool tusd balance old after: ", tusdBalanceContractOldAfter);
    //     console2.log("pool tusd balance new after: ", tusdBalanceContractNewAfter);
    //     console2.log("mev tusd balance after: ", tusdBalanceMevAfter);
    //     console2.log("mev eth balance after: ", ethBalanceMevAfter);

    //     console2.log("estimatedOut after", estimatedOutAfter );

    //     console2.log("actual out: ", actualOut);

    //     // Assert pool eth balance after is  

    //     // Assert that the actual return value matches the expected value
    //     assertEq(estimatedOut, expectedOut);
    // }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../src/interfaces/IERC20.sol";
import {CompoundLiquidator} from "../src/CompoundLiquidator.sol";
import {ICERC20} from "../src/interfaces/ICERC20.sol";
import {Test, console2} from "forge-std/Test.sol";

contract CompoundLiquidatorTest is Test {
    ICERC20 public cDAI = ICERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    ICERC20 public cETH = ICERC20(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    
    address daiWhale = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address userToLiquidate = 0x26DB83C03F408135933b3cFF8b7adc6A7e0ADEbc;
    uint256 repayAmount = 5316186245975314792583;

    CompoundLiquidator public liquidator;

    function setUp() public {
        liquidator = new CompoundLiquidator();
        
        console2.log("DAI whale balance", dai.balanceOf(daiWhale));

        vm.startPrank(daiWhale);

        dai.transfer(address(liquidator), 10000 ether);

        vm.stopPrank();
    }

    // Replicating this transaction: https://etherscan.io/tx/0xec4f2ab36afa4fac4ba79b1ca67165c61c62c3bb6a18271c18f42a6bdfdb533d
    // Works witn an anvil fork on block 10692539
    function testLiquidate() public {
        uint256 daiBalanceBefore = dai.balanceOf(address(liquidator));
        uint256 cEthBalanceBefore = cETH.balanceOf(address(liquidator));

        console2.log("DAI balance before: ", daiBalanceBefore);
        console2.log("cETH balance before: ", cEthBalanceBefore);

        bytes memory messageEth = hex"0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000005f3d826800000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000017afc4380000000000000000000000000000000000000000000000000000000000000006707269636573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034554480000000000000000000000000000000000000000000000000000000000";
        bytes memory messageDai = hex"0000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000005f3d826800000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000f5caf0000000000000000000000000000000000000000000000000000000000000006707269636573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034441490000000000000000000000000000000000000000000000000000000000";

        bytes memory signatureEth = hex"d0ba2ec311667df4c2bec668b5666ce952d1373154d0393b01d937d26e19533d603ccf65290fa9b475064f039a41398954706c9417781de51a112fdd4d283c3d000000000000000000000000000000000000000000000000000000000000001b";
        bytes memory signatureDai = hex"fa8211125a669ec79f429a412aca359e411866c4bd35d7ab0bdb7749585726327c72e5fbd9e79fee3b185a89ad228090a7026058b572ea3e3e1c0038ec97686f000000000000000000000000000000000000000000000000000000000000001b"; 

        string memory symbolEth = "ETH";
        string memory symbolDai = "DAI";

        bytes[] memory messages = new bytes[](2);
        bytes[] memory signatues = new bytes[](2);
        string[] memory symbols = new string[](2);

        messages[0] = messageEth;
        messages[1] = messageDai;

        signatues[0] = signatureEth;
        signatues[1] = signatureDai;

        symbols[0] = symbolEth;
        symbols[1] = symbolDai;
        
        console2.log("Liquidating user: ", userToLiquidate);
        liquidator.liquidate0000001(messages, signatues, symbols, userToLiquidate, address(cETH), address(cDAI), repayAmount);

        uint256 cEthBalanceAfter = cETH.balanceOf(address(liquidator));
        uint256 daiBalanceAfter = dai.balanceOf(address(liquidator));

        console2.log("DAI balance after: ", daiBalanceAfter);
        console2.log("cETH balance after: ", cEthBalanceAfter);

        assertGt(cEthBalanceAfter, 0);
    }
}
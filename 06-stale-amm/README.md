It’s May 2021, and while searching for new trading pools, you discovered that someone made [2.8x](https://etherscan.io/tx/0x3f1b5baef6ea7f622834eabe7634bf89e3f473b62a73e357fdd04a1a5cf32ecf) by selling TUSD through one of the old Uniswap v1 pools. Let’s figure out how it happened.

## a) What is the reason for the stale price in this pool?
- Uniswap V1 pools only have pairs against ETH. They store a single variable of the other token in the pair called `tokenAddress`.
- TUSD migrated their token on Jan-04-2019 from an [old contract](https://www.notion.so/dd13fb489070d432dfa89a0b93315d8b?pvs=21) (henceforth, `TUSDOLD`) to [a new Smart Contract](https://www.notion.so/06-Stale-AMM-f99742aefdc94742bf17f3c58e8e965e?pvs=21) (henceforth, `TUSD`). Anticipating a potential token migration and to allow backward compatibility, the team added a mechanism to forward calls to the new token smart contract. For example, if an account called the `transfer` function on `TUSDOLD`, the contract would call `transfer` on TUSD.
- This pool was created on Dec-19-2018, before the migration occurred. It has the address of `TUSDOLD` registered as `tokenAddress`.
- Programmatic bots typically reconstruct the chain using the `tokenAddress` stored on-chain. However, after the migration, events on `TUSDOLD` ceased, as they were emitted on the new implementation. Consequently, this pool would fly under the radar of generic bot implementations.
    
## b) Provide all necessary simulation data to arbitrage the pool on January 23, 2022.
- As of January 23, 2022, the pool's reserves are as follows:
    - Pool ETH balance: 0.6715786432016406
    - Pool TUSD balance: 2405.261049243413614839
    - ETH price (according to Coingecko): $1630.84
    - TUSD price(according to Coingecko): $1
    - Pool ETH value: 1095.23731
- This indicates a clear imbalance in the pool, with TUSD outweighing ETH. An arbitrage opportunity exists through an ETH to TUSD trade. The pool's imbalance has shifted direction from the previous example due to the decline in ETH's price during this period.
- To demonstrate this arbitrage opportunity, we'll use a simple example with 0.1 ETH. While the optimal amount for maximizing profit could be calculated using a binary search, this simplified approach yields the following results:
    - **Amount in**: 0.1 ETH
    - **Amount in value**: $163.84
    - **Amount out**: 310.92 TUSD
    - **Amount out value**: $310.92
    - **ROI**: 1.897x
    - **Total estimated profit:** $310
- All the simulation can be found under the folder `./simulation`
- The logical next step would be to atomically close the trade on a more liquid pool (e.g., Uniswap V2). However, this was beyond the scope of the test.

To run the test in question, do the following:

1. Use `14058541` to fork mainnet with anvil.
2. Run the test
 `forge test --match-path simulation/test/StaleAmm.t.sol --fork-url  [http://127.0.0.1:8599](http://127.0.0.1:8599/) -vvv`

```shell
forge test --match-path test/StaleAmm.t.sol --via-ir --fork-url  http://127.0.0.1:8599 -vv 

[⠊] Compiling...
[⠘] Compiling 26 files with Solc 0.8.24
[⠃] Solc 0.8.24 finished in 3.83s
Compiler run successful!

Ran 1 test for test/StaleAmm.t.sol:StaleAmm
[PASS] testArbitrageJan232022() (gas: 112081)
Logs:
  tusdWhale balance:  361392906071290000000000
  contract eth balance before:  671578643201640554
  contract tusd balance old before:  2405261049243413614839
  contract tusd balance new before:  2405261049243413614839
  sender tusd balance before:  10000000000000000000000
  sender eth balance before:  671578643201640554
  Estimated out:  310918147057878056631
  contract eth balance after:  771578643201640554
  contract tusd balance old after:  2094342902185535558208
  contract tusd balance new after:  2094342902185535558208
  sender tusd balance after:  338004006012642218355
  sender eth balance after:  771578643201640554
  estimatedOut after 36728813024969
  actual out:  310918147057878056631

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 42.92ms (2.09ms CPU time)

Ran 1 test suite in 436.17ms (42.92ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
```

## c) Could you execute the arbitrage on March 14, 2022? If not, explain why.
- No. The TUSD token contract was updated on February 24, 2022 (block 14266480) [after a vulnerability was discovered](https://blog.openzeppelin.com/compound-tusd-integration-issue-retrospective) in its Compound market due to its double-entry nature. After this block, the contract reverts on any interaction with the old pool.

To answer question b) and understand the nature of the problem, we created a test using Foundry. To view the results obtained for b), follow these steps:

1. Run a Mainnet fork. If using Anvil, execute the following command::

`anvil --fork-url ARCHIVE_NODE_RPC -p 8599`

1. Run the test by doing:

 `forge test --match-path simulation/test/StaleAmm.t.sol --fork-url  [http://127.0.0.1:8599](http://127.0.0.1:8599/) -vvv`

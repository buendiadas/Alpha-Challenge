# Pump-It - Tier 2
You notice the growing attention around pump.fun and can't help but take a deeper look. You are interested in their revenue sources and observe that they take fees for a few distinct actions.


### a) How much revenue did Pump generate and can you decompose this for each action? E.g. [pump.fun](http://Pump.Fun) takes fees for each trade on the bonding curve, so one revenue component would be the sum of all “trades via the bonding curve” (the distinct action).

Fees from trading go to [this address](https://solscan.io/account/CebN5WGQ4jvEPvsVU4EoHEpgzq1VV7AbicfhtW4xC9iM), which currently holds 308,151.8 SOL($40,971,863.57) and $38.8M USDC. Fees are collected in sol, but the account [sold part of their treasury](https://solscan.io/tx/4rebhjk89XHw8vxfM6c9sRn2vgE9htPueHMiwJtS6a4oHKP7XVJRVx2CjVXddEaQ3RwHQWw9Mgz5pETmM4kk4jV3) to USDC. [This query](https://dune.com/queries/3994714/6723544/) tracks the value of this fee account incrementally by transactions, to track the revenue per day. Using this methodology the estimated total revenue is calculated at is **679,947 SOL**, or  **$101,650,360**. 

Pump fun has two different sources of revenue: 
1. **Migration fees**: Whenever a pool reaches a market cap of $69k, the liquidity is migrated to Raydium, using [this account]https://solscan.io/account/39azUYFWPz3VHgKCf3VChUwbpURdCHRxjWVowf5jUJjg#defiactivities

![alt text](image-1.png)

The revenue is made by taking a cut to the total amount of SOL liquidity which is stored in the bonding curve. To find how much revenue was made using migration fees, we can filter the transactions made from the migration account to the fee account, getting a total revenue of:

![alt text](image-2.png)

`>>> 2900 + 6600 + 1900 + 5000 + 6300 + 9500 + 3900 + 2600 + 2300 + 4300 + 2230 (curr balance) = 47530 SOL`

So the total amount found using this approach was 45300 SOL ($6.35M at current prices)


1. **Bounding curve swap fees**: A 1% fee that is charged to every user who trades on the bonding curve. 

![alt text](image.png)

Given that we didn't find any other fee, we can assume the rest of the revenue cam from bonding curve swap fees: 

`679947 - 47530 = 632417 SOL`
 
### b) What percentage of tokens were successfully deployed to Raydium? Find the tokens that:
    - Took the most time to deploy to Raydium.
    - Took the least amount of time to deploy to Raydium.
### c) Using the information gained from the above sub-questions about fee generation, were there any cases where the pump team had a clear incentive to buy any given token created through their platform? If yes, provide an example. If no, explain the conditions under which this incentive would exist.

The team has an incentive to buy (pump) the price when the market cap approaches the migration market cap (currently 69k) to ensure they receive the migration fees. For example, a token might eventually require only a $1 purchase in the bonding curve to migrate. In this case, the team would be strongly motivated to spend that $1 to secure the entire migration fee.

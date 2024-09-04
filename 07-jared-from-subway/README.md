# Jared-from-Subway - Tier 2
You are click trading a newly launched memecoin and notice you are being sandwiched by [Jared](https://etherscan.io/address/0x6b75d8af000000e20b7a7ddf000ba900b4009a80). You see that Jared made a bunch of money doing this, and you're interested in checking their profitability:


## a) Produce the code to calculate Jared’s revenue.
We can estimate Jared's revenue calculating the net inflows / outflows of each asset ant then calculate the assets he holds, or the value delta at the time of transaction. We will do the former, calculate the total revenue per asset and then we can translate that into ETH or USD. 

The net inflows / outflows for assets will be 0 for those assets where the balance is 0. We can calculate the total inflows / outflows for the rest of the assets currently in balance, as seen in the following Dune query:

https://dune.com/queries/4036022/6795366/269aeeee-9d8d-4d47-97bd-ed04cb799ab1

In USD terms this means a total of $238.09731M


## b) Produce the code to calculate Jared’s costs and use this to
We can assume all costs came from gas costs, since Jared does't externally pays validators, [according to this report](https://eigenphi.substack.com/p/performance-appraisal-of-jaredfromsubway-eth)
https://dune.com/queries/4037308/6797412/73f86d57-7290-43c6-825a-c9de632e7d5d

We get as a result a total cost of *84428.32491618101 ETH* which means $213.7725M 

###   - Compute their profit.

We can calculate its profit as the `total_revenue_usd` - `total_cost_usd` = 238.09731 - $213.7725M = $24.32M

###    - Identify the opportunity that yielded the highest single profit.

To identify that opportunity it is required the following:
1. Calculating the net flows per block of all tokens
2. Having a price for each one of the tokens for that block
3. Calculating the total value delta as SUM(net flows) * PRICE
4. Substract gas costs

My aproach above has not been using prices per block, but only calculating the delta value after all transfers. I attach an imperfect query doing the calculation only taking into account weth inflows:

https://dune.com/queries/4044932/6810848/31da048c-edd6-4550-861e-fe1d166ed9cf

## c) How can you avoid being sandwiched in the future? Provide some reasons that might explain why Jared is out-competing other sandwich enjoyers.

To prevent against being sandwitched you can do different measures: 
- Use an intent based DEX (e.g 1inch fusion): Trading this way you delegate the execution to a third party solver, who will give you the best price that he can get on the market, keeping a fee in exchange.
- Use private RPCs (e.g Flashbot protect RPC, MEV Blocker), so that your transaction is not seen by MEV bots

On why Jared is might be out-competing other sandwich enjoyers:
- **First mover advantage**: While MEV is a continuously evolving field (which might suggest high rotation of winners) it usually tends to be a winner takes all market. There are many reasons for this,    but one of them is that the continuous evolution of this market makes strategies more and more sofisticated, increasing the entry barrier to any new aspirant MEV developer, and lowering their chances of success.
- **Visibility on more type of trades**: usually, sandwiches are most profitable on long tail niches, where the market is not completely saturated, and there are margins for solvers.
- **Capability of running with low costs**. While this is usually a more necessary than sufficient requirement, one of the most important variables on gas bid type MEV is the amount of gas you are able to spend on a transaction, since that increases your budget to bid. 
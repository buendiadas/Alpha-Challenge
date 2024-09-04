# Solana-Stake - Tier 3
The Solana Foundation [recently announced](https://www.theblock.co/post/299244/solana-foundation-removes-certain-operators-from-delegation-program-over-malicious-sandwich-attacks) their plan to remove stake from their delegation program if participating validators produce blocks including sandwich attacks.

Here is a [useful thread](https://x.com/0xMert_/status/1799955514786234751) for extra context, also you can view the announcement on the foundation’s Discord.


- a) You are aware of Jito's modified Solana client to improve the efficiency of MEV extraction. Describe how unaligned validators can run their own private mempool to facilitate sandwich attacks.
  - They can broadcast transactions to searchers ahead of finality, providing them an oportunity to execute MEV strategies, like frontrunning or backrunning transactions.
- b) Identify the validators that had their stake removed, and determine the total amount removed.


- c) Write code that, given a Solana block, outputs whether a sandwich attack was included.
I will not be on time for this one, so I will explain how I would do it:
1. Sorting Swaps: First, sort the swaps by their transaction position
2. Iterate Over the Swaps: For each swap, check if it could be the start of a potential sandwich attack, iterating back through the rest.
3. Identifying Potential Sandwiches:
  a. Compare the current swap with the rest of the swaps in the list, looking for transactions in the same contract (likely the same liquidity pool).
  b. Find a swap that matches the same token pair but from a different user,
  c. Search for a "backrun" swap by the attacker, where the attacker swaps the tokens back, fulfilling the sandwich pattern. 

One of the most famous repos identifying sandwiches is `mev-inspect`

https://github.com/flashbots/mev-inspect-py/blob/main/mev_inspect/sandwiches.py
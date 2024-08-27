# Long-Tail-Enjoyor - Tier 3
You’re an active member of the Synthetix community and noticed that the implementation of one of [their latest SIPs](https://sips.synthetix.io/sips/sip-112/) will be deployed today (May 13, 2021).


- a) How, in theory, can you make money based on the SIP specification?
    You can either:
     - mint sETH 1:1 with weth and sell it on the secondary markets when price is above peg, or
     - Buy it at a discount on secondary markets and sell it to this contract when it is trading below peg on secondary markets.
- b) Provide the simulation data when you execute the opportunity using the full `maxETH` amount.
    It can be found attached an example doing an arbitrage on block `12581549`, where actually used the mechanism to make a profit. 
    
    On this example, the capacity of the wrapper was only 2 ETH, so, even if we asked for `maxETH`, we would receive just 2 ETH. We will get back to the problem to try to find another bigger opportunity, where we can actually use the full `maxETH` (capacity full).

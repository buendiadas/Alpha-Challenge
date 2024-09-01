# Whitehat - Tier 2
You stumbled across an old [bug bounty report](https://medium.com/immunefi/polygon-lack-of-balance-check-bugfix-postmortem-2-2m-bounty-64ec66c24c7d) from the end of 2021 related to the Polygon codebase. Understanding that other blockchains are using this code, you decide to double-check that the largest ones are not susceptible to vulnerabilities disclosed in this report.

*To simplify calculations the solution provided for this exercise is assuming we found the old [bug bounty report](https://medium.com/immunefi/polygon-lack-of-balance-check-bugfix-postmortem-2-2m-bounty-64ec66c24c7d) today. Out of the 2 forks identified, one (BTCC) could have been vulnerable on the dates that this vulnerability was disclosed. The other, Shibarium, was deployed later, but we analyze if the MRC20 code deployed was outdated*

##  a) Find at least two Polygon forks that could potentially be vulnerable. 
We found two different forks:

 ### 1 - Bittorrent chain (BTT):
BitTorrent chain is a sidechain solution who forked the contracts from Polygon (including the problematic MRC20 contract). This network had it [genesis block](https://bttcscan.com/block/0) on **December, 10 2021** which is only **7 days after it was first reported** on to Matic and 5 days after the fix was published.


The [committed a fix](https://github.com/bttcprotocol/contracts/commit/8ce227c6bd977f8cd902d13e09730453b39d8c74) to the `transfersWithSignature` to their public repository on December 30 (one day after the public announcement of the vulnerability on polygon), with an [identical change](https://github.com/maticnetwork/contracts/commit/55e8118ad406c9cb0e9b457ca4f275c5977809e4) of the one included on polygon, which might suggest they might have deployed the old contracts, including the vulnerability. However this also means the contract is not susceptible to any vulnerability disclosed in the report.
 
 Their network token can be found at the same predeployed address as Matic, and it holds most of the supply of the token.

https://bttcscan.com/address/0x0000000000000000000000000000000000001010
 

 ### 2 - Shibarium
Shibarium (shiba) also have proof of stake Ethereum sidechain using the plasma bridge to provide communication from L1. While their public github was harder to comprehend they were forking the Matic contracts, it is clear by looking at [their docs](https://docs.shib.io/docs/shibarium/bridge-assets/ethereum-to-shibarium). Their Genesis block was on Aug, 5, 2023, so this deployment came after the vulnerability report, and has less chances of having a vulnerable deployment, however, we can 

 Their network token is [$BONE](https://www.coingecko.com/en/coins/bone-shibaswap), and the token can be found at the same predeployed address as Matic, holding most of the supply of the token: 

 https://www.shibariumscan.io/address/0x0000000000000000000000000000000000001010

## b) Provide the code to check if these blockchains are safe.

It is possible to reuse the same hardhat script that was created on inmunefi for Polygon to check the vulnerability on both chains, as all parameters (even the precomputed address) are simmilar. 

https://github.com/immunefi-team/polygon-transferwithsig?tab=readme-ov-file&utm_source=immunefi

To be able to execute them, however, it is necessary to have access to an archive node of both chains, which is something I don't currently have access to, but could be achieved by just downloading a full archive node or accessing some of the paid RPC nodes available. For example, for BTCC [there is an ankr node available](https://www.ankr.com/rpc/bttc/).


## c) Estimate the potential maximum loss if this attack is possible on both blockchains.

In both cases, as in Matic, the maximum loss can be estimated as the total balance held by the predefined 0x0000000000000000000000000000000000001010 contract, which

To estimate the potential maximum loss if the attack is possible, we need to know the following params:
 1. Price of the token.
 2. Balance of the token held by the 0x0000000000000000000000000000000000001010 token address on the target date.
 
**Bittorrent Chain** 

- Date: Sun, September 1, 2024
- Price of BTT: 0.000000836346 (Coingecko)
- Balance of the token held by 0x0000000000000000000000000000000000001010: 9971691824409970 BTT
- Equivalent value at risk: 8.341Bn*

The lattest value is theoreticall, and doesn't represent the real value an attacker could actually sell right now, but the full amount he could receive of BTT at the current price.


**Shibarium**
 - Date: Sun, September 1, 2024
 - Price of Bone: $0.4 (Coingecko)
 - Balance of the token held by 0x0000000000000000000000000000000000001010: 240,601,472 BONE
 - Equivalent value at risk: 96.48M


*Given the discrepancy with Coingecko FDV I researched to ensure the high number above wasn't wrong and found out they are using to calculate the FDV the Tron token API: https://apilist.tronscan.org/api/token/fund?token=newbtt), which seems to be 1000 lower, I think the total supply of the BTCC token on their own chain might better represent the value the user could mint to themselves*
# Stale-Oracle - Tier 1
While digging around, you learn about the manual process involved in updating oracle prices for [Compound v1](https://etherscan.io/address/0x3fda67f7583380e67ef93072294a7fac882fd7e7). According to the official blog post, the protocol was deprecated on June 3, 2019. However, according to the contract, it was never paused, and there are no functions for freezing markets. Given this, perhaps it’s possible to use stale prices and borrow all assets cheaply?


- a) Are the prices stale according to the view of Compound v1?

In Compound v1, the price oracle was updated manually by an administrator or through an external process. This meant that if an administrator didn't update the prices, the protocol could be using outdated or stale prices, as there was no check for stale prices in the protocol code.

- b) Were markets paused in some way? Provide all necessary data to simulate the borrowing of any asset on June 5, 2019 to prove your point.
Yes, borrow transactions were disabled, which removes the risk of producing bad debt to the provided assets. https://medium.com/compound-finance/compound-v1-deprecation-schedule-b345115575d9  
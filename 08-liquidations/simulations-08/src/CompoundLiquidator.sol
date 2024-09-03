// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IUniswapAnchoredView.sol";
import "./interfaces/ICERC20.sol";

contract CompoundLiquidator {
    address private constant COMPOUND_PRICE_FEED_ADDRESS = 0x9B8Eb8b3d6e2e0Db36F41455185FEF7049a35CaE;

    function liquidate0000001(
        bytes[] calldata messages,
        bytes[] calldata signatures,
        string[] calldata symbols,
        address _liquidatedAccount,
        address _collateralToken,
        address _debtToken,
        uint _repayAmount
    ) public {
        // 1. Post price data to Compound Oracle
        IUniswapAnchoredView(COMPOUND_PRICE_FEED_ADDRESS).postPrices(messages, signatures, symbols);

        IERC20(ICERC20(_debtToken).underlying()).approve(_debtToken, _repayAmount);

        // 2 Liquidate the account
        ICERC20(_debtToken).liquidateBorrow(_liquidatedAccount, _repayAmount, _collateralToken);
    }
}

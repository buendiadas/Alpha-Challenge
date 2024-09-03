// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Vault is ERC4626 {
    constructor(IERC20Metadata asset) ERC4626(asset) ERC20("Vault", "VAULT") {
        // You can add any additional setup code here if needed
    }

    // Implement any required virtual functions here if necessary
}
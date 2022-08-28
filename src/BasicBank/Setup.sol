// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "./StakingToken.sol";
import "./BasicBank.sol";

contract Setup {
    StakingToken public stakingToken;
    BasicBank public basicBank;

    constructor() {
        stakingToken = new StakingToken(msg.sender);
        basicBank = new BasicBank(stakingToken);
    }
}

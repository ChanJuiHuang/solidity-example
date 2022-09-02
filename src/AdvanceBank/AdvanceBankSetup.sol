// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "../BasicBank/StakingToken.sol";
import "./RewardToken.sol";
import "./AdvanceBank.sol";

contract AdvanceBankSetup {
    StakingToken public stakingToken;
    RewardToken public rewardToken;
    AdvanceBank public advanceBank;

    constructor() {
        stakingToken = new StakingToken(msg.sender);
        rewardToken = new RewardToken(msg.sender);
        advanceBank = new AdvanceBank(address(stakingToken), address(rewardToken));
    }
}

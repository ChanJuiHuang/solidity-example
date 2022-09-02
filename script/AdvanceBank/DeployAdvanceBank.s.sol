// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "src/AdvanceBank/AdvanceBankSetup.sol";

contract DeployAdvanceBankScript is Script {
    function run() public {
        vm.startBroadcast();
        StakingToken stakingToken = new StakingToken(msg.sender);
        RewardToken rewardToken = new RewardToken(msg.sender);
        new AdvanceBank(address(stakingToken), address(rewardToken));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "src/Lottery/Lottery.sol";

contract DeployLottery is Script {
    uint64 subscriptionId = 322;

    function run() public {
        vm.broadcast();
        new Lottery(subscriptionId);
    }
}

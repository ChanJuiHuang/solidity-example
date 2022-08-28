// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.4;

import "forge-std/Script.sol";
import "src/BasicBank/Setup.sol";

contract BasicBankScript is Script {
    Setup private setup;
    address address1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address address2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address address3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    BasicBank private basicBank;
    StakingToken private stakingToken;

    function setUp() public {
        vm.startBroadcast(address1);
        setup = new Setup();
        basicBank = setup.basicBank();
        stakingToken = setup.stakingToken();
        stakingToken.transfer(address(basicBank), 10000 ether);
        stakingToken.transfer(address2, 10000);
        vm.stopBroadcast();
        console.log("staking token balance of %s: [%d]", address1, stakingToken.balanceOf(address1));
        console.log("staking token balance of basic bank: [%d]", stakingToken.balanceOf(address(basicBank)));
        console.log("staking token balance of %s: [%d]", address2, stakingToken.balanceOf(address2));
    }

    function run() public {
        vm.startBroadcast(address2);
        stakingToken.approve(address(basicBank), 1000);
        uint256 startAt = 0;
        uint256 endAt = 30 seconds;
        vm.warp(startAt);
        basicBank.deposit(1000);
        vm.warp(endAt);
        basicBank.withdraw(0);
        console.log("deposit interest trial calculation: %d", basicBank.depositInterestTrialCalculation(startAt, endAt, 1000));
        console.log("balance of %s [%d]", address2, stakingToken.balanceOf(address2));
        console.log("****************************************************************");
        stakingToken.approve(address(basicBank), 1000);
        endAt = 61 seconds;
        vm.warp(startAt);
        basicBank.lockToken(1, 1000);
        vm.warp(endAt);
        basicBank.unlockToken(0);
        (uint32 period, uint32 interestRate) = basicBank.lockedStakings(1);
        console.log("locked staking interest trial calculation: %d", basicBank.lockedStakingInterestTrialCalculation(period, interestRate, 1000));
        console.log("balance of %s [%d]", address2, stakingToken.balanceOf(address2));
    }
}

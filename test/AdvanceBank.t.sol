// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/AdvanceBank/AdvanceBankSetup.sol";

contract AdvanceBankTest is Test {
    AdvanceBankSetup private advanceBankSetup;
    address address1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address address2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 initialAmount = 10000;
    AdvanceBank private advanceBank;
    StakingToken private stakingToken;
    RewardToken private rewardToken;

    function setUp() public {
        vm.startBroadcast(address1);
        advanceBankSetup = new AdvanceBankSetup();
        advanceBank = advanceBankSetup.advanceBank();
        stakingToken = advanceBankSetup.stakingToken();
        rewardToken = advanceBankSetup.rewardToken();

        stakingToken.transfer(address(advanceBank), 10000 ether);
        rewardToken.transfer(address(advanceBank), 10000 ether);
        stakingToken.transfer(address2, initialAmount);
        vm.stopBroadcast();
        console.log("staking token balance of %s: [%d]", address1, stakingToken.balanceOf(address1));
        console.log("staking token balance of advance bank: [%d]", stakingToken.balanceOf(address(advanceBank)));
        console.log("staking token balance of %s: [%d]", address2, stakingToken.balanceOf(address2));
        console.log("reward token balance of advance bank: [%d]", rewardToken.balanceOf(address(advanceBank)));
    }

    function testDeposit() public {
        vm.startBroadcast(address2);
        uint256 depositAmount = 1000;
        stakingToken.approve(address(advanceBank), depositAmount);
        uint256 startAt = 0;
        uint256 endAt = 30 seconds;
        vm.warp(startAt);
        advanceBank.deposit(depositAmount);
        vm.warp(endAt);
        advanceBank.withdraw(0);
        assertEq(advanceBank.depositInterestTrialCalculation(startAt, endAt, depositAmount), rewardToken.balanceOf(address2));
        assertEq(initialAmount, stakingToken.balanceOf(address2));
    }

    function testLockToken() public {
        vm.startBroadcast(address2);
        stakingToken.approve(address(advanceBank), 1000);
        uint256 startAt = 0;
        uint256 endAt = 61 seconds;
        vm.warp(startAt);
        advanceBank.lockToken(1, 1000);
        vm.warp(endAt);
        advanceBank.unlockToken(0);
        (uint32 period, uint32 interestRate) = advanceBank.lockedStakings(1);
        assertEq(advanceBank.lockedStakingInterestTrialCalculation(period, interestRate, 1000), rewardToken.balanceOf(address2));
        assertEq(initialAmount, stakingToken.balanceOf(address2));
    }
}

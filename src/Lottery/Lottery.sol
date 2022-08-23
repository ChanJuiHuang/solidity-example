// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./VRFv2Consumer.sol";

contract Lottery is VRFv2Consumer {
    uint256 public cumulativeReward;
    uint256 public minimusBetAmount = 1000000000000000 wei;
    uint256 public cumulativeRewardThreshold = 2000000000000000 wei;
    uint256 public randomNumber;
    uint256 public scheduleExpiredAt;
    mapping (address => uint256) public betAmounts;
    address[] public participants;
    uint8 public participantLimit = 30;
    bool public isEnabled;
    bool public isBack;

    constructor(uint64 _subscriptionId) VRFv2Consumer(_subscriptionId) {
    }

    function enter() public payable {
        require(msg.value >= minimusBetAmount, "Your bet amount is not enough.");
        require(participants.length <= participantLimit, "Over the participant limit.");
        cumulativeReward = cumulativeReward + msg.value;

        if (betAmounts[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        betAmounts[msg.sender] = betAmounts[msg.sender] + msg.value;
    }

    function openNewSchedule(uint256 schedulePeriod) public onlyOwner {
        require(!isEnabled, "This schedule of lottery is in process.");
        isEnabled = true;
        cumulativeReward = 0;
        isBack = false;
        scheduleExpiredAt = block.timestamp + schedulePeriod;
        delete participants;
    }

    function pickWinner() public onlyOwner {
        require(cumulativeReward >= cumulativeRewardThreshold, "CumulativeRewardThreshold does not reach!");
        require(scheduleExpiredAt >= block.timestamp, "Exceed schedule expiration time.");
        getRandomNumber(1);
    }

    function transferCumulativeRewardToWinner() public {
        require(isBack, "Waiting for chainlink...");
        uint256 index = randomNumber % participants.length;
        payable(participants[index]).transfer(cumulativeReward);
        isEnabled = false;
    }

    function reundCumulativeReward() public {
        require(block.timestamp >= scheduleExpiredAt, "This schedule of lottery is in process.");
        for (uint256 i = 0; i < participants.length; i++) {
            payable(participants[i]).transfer(betAmounts[participants[i]]);
        }
        isEnabled = false;
    }

    function setParticipantLimit(uint8 _participantLimit) public onlyOwner {
        require(!isEnabled, "This schedule of lottery is in process.");
        participantLimit = _participantLimit;
    }

    function getRandomNumber(uint32 numWords) private {
        VRFv2Consumer.requestRandomWords(numWords);
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        randomNumber = randomWords[0];
        isBack = true;
    }

    function getTotalParticipants() public view returns (uint256) {
        return participants.length;
    }
}

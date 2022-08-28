// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

struct depositRecord {
    uint256 amount;
    uint256 depositedAt;
}

struct LockedStaking {
    uint32 period;
    uint32 interestRate;
}

struct LockedStakingRecord {
    uint256 amount;
    uint256 createdAt;
    LockedStaking lockedStaking;
}

contract BasicBank is Ownable {
    uint256 public minimumDepositAmount = 100;
    mapping(address => depositRecord[]) private depositRecords;
    IERC20 public stakingToken;
    uint32 public depositRates = 10;
    LockedStaking[] public lockedStakings;
    mapping(address => LockedStakingRecord[]) private lockedStakingRecords;

    event EarnDepositInterest(address indexed from, uint256 amount);
    event EarnLockStakingInterest(address indexed from, uint32 period, uint32 interest, uint256 amount, uint256 createdAt);

    constructor(IERC20 _stakingToken) Ownable() {
        stakingToken = _stakingToken;
        lockedStakings.push(LockedStaking({
            period: 30 seconds,
            interestRate: 20
        }));
        lockedStakings.push(LockedStaking({
            period: 60 seconds,
            interestRate: 30
        }));
    }

    function deposit(uint256 _amount) external checkDepositAmount(_amount) {
        depositRecords[msg.sender].push(depositRecord({
            amount: _amount,
            depositedAt: block.timestamp
        }));
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit EarnDepositInterest(msg.sender, _amount);
    }

    function lockToken(uint256 _index, uint256 _amount) external checkDepositAmount(_amount) {
        LockedStakingRecord memory lockedStakingRecord = LockedStakingRecord({
            lockedStaking: lockedStakings[_index],
            amount: _amount,
            createdAt: block.timestamp
        });
        lockedStakingRecords[msg.sender].push(lockedStakingRecord);
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit EarnLockStakingInterest(
            msg.sender,
            lockedStakings[_index].period,
            lockedStakings[_index].interestRate,
            _amount,
            lockedStakingRecord.createdAt
        );
    }

    function withdraw(uint256 _index) external {
        uint256 interest = depositInterestTrialCalculation(depositRecords[msg.sender][_index].depositedAt, block.timestamp, depositRecords[msg.sender][_index].amount);
        uint256 depositAmount = depositRecords[msg.sender][_index].amount;
        uint256 lastIndex = depositRecords[msg.sender].length - 1;

        if (_index != lastIndex) {
            depositRecords[msg.sender][_index] = depositRecords[msg.sender][lastIndex];
        } else {
            depositRecords[msg.sender].pop();
        }
        stakingToken.transfer(msg.sender, (depositAmount + interest));
    }

    function unlockToken(uint256 _index) external {
        uint32 period = lockedStakingRecords[msg.sender][_index].lockedStaking.period;
        uint256 createdAt = lockedStakingRecords[msg.sender][_index].createdAt;
        require((block.timestamp - createdAt) > period, "Lock time does not reach");
        uint256 interest = lockedStakingInterestTrialCalculation(
            period,
            lockedStakingRecords[msg.sender][_index].lockedStaking.interestRate,
            lockedStakingRecords[msg.sender][_index].amount
        );
        uint256 lockedAmount = lockedStakingRecords[msg.sender][_index].amount;
        uint256 lastIndex = lockedStakingRecords[msg.sender].length - 1;

        if (_index != lastIndex) {
            lockedStakingRecords[msg.sender][_index] = lockedStakingRecords[msg.sender][lastIndex];
        } else {
            lockedStakingRecords[msg.sender].pop();
        }
        stakingToken.transfer(msg.sender, (lockedAmount + interest));
    }

    function setDepositRates(uint32 _depositRates) external onlyOwner {
        depositRates = _depositRates;
    }

    function setLockedStakings(LockedStaking[] calldata _lockedStakings) external onlyOwner {
        delete lockedStakings;

        for (uint256 i = 0; i < _lockedStakings.length; i++) {
            lockedStakings.push(_lockedStakings[i]);
        }
    }

    function setMinimumDepositAmount(uint256 _minimumDepositAmount) external onlyOwner {
        minimumDepositAmount = _minimumDepositAmount;
    }

    function getDepositRecords(address _from) external view returns(depositRecord[] memory) {
        require(msg.sender == _from, "You are not owner!");

        return depositRecords[_from];
    }

    function getLockedStakingRecords(address _from) external view returns(LockedStakingRecord[] memory) {
        require(msg.sender == _from, "You are not owner!");

        return lockedStakingRecords[_from];
    }

    function depositInterestTrialCalculation(uint256 _startAt, uint256 _endAt, uint256 _amount) public view returns(uint256) {
        uint256 interest = (_endAt - _startAt) * _amount * depositRates / 100 / (365 seconds);

        return interest;
    }

    function lockedStakingInterestTrialCalculation(uint32 _period, uint32 _interestRate, uint256 _amount) public pure returns(uint256) {
        uint256 interest = _period * _interestRate * _amount / 100 / (365 seconds);

        return interest;
    }

    modifier checkDepositAmount(uint256 _amount) {
        require(_amount >= minimumDepositAmount
            && (_amount % minimumDepositAmount) == 0,
            "You deposit amount is wrong!"
        );
        _;
    }
}

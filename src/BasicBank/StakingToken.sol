// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20("Staking Token", "ST") {
    constructor(address _from) {
        _mint(_from, 10000000 ether);
    }
}

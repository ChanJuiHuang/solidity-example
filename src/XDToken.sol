// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract XDToken is ERC20 {
    uint256 private _totalSupply = 10000;
    address payable private owner;

    constructor() ERC20("XDToken", "XD") {
        owner = payable(msg.sender);
        _mint(msg.sender, _totalSupply);
    }

    // @note 1 eth can buy 1 XD Token!
    function buyToken() public payable {
        uint256 tokenAmount = msg.value / (1 ether);
        _transfer(address(owner), msg.sender, tokenAmount);
    }

    function balanceOfEther() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}

    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner, "You are not the owner~XDDD");
        owner.transfer(amount);
    }

    function destroyContract() public {
        require(msg.sender == owner, "You are not the owner");
        selfdestruct(owner);
    }
}

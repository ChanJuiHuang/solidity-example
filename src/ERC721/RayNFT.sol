// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "./NFTStore.sol";

contract RayNFT is ERC721, NFTStore {
    using Counters for Counters.Counter;

    uint256 public publicNumber = 10;
    Counters.Counter private remainingNFT;
    address payable private owner;

    constructor() ERC721("RayNFT", "RayNFT") {
        owner = payable(msg.sender);
        remainingNFT._value = publicNumber;
        mintSuperNFT();
        initializeStore(publicNumber);
    }

    function mint(uint8 tokenId) public payable {
        require((tokenId >= 0 && tokenId < publicNumber), "Token id is not in range.");
        require(msg.value == publicNFTs[tokenId].price, "Your payment is wrong.");

        remainingNFT.decrement();
        _mint(msg.sender, tokenId);
    }

    receive() external payable {}

    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner, "You are not the owner~XDDD");
        owner.transfer(amount);
    }

    function mintSuperNFT() private {
        _mint(address(owner), 10);
    }
}

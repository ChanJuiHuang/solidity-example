// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract XDNFT is ERC721 {
    using Counters for Counters.Counter;

    uint256 totalSupply = 2;
    Counters.Counter private remainingNFT;
    address payable private owner;

    constructor() ERC721("XDNFT", "XDNFT") {
        owner = payable(msg.sender);
        remainingNFT._value = totalSupply;
        initMint();
    }

    function transfereNFTs(uint256[] calldata tokenIds, address to) public {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            transferFrom(msg.sender, to, tokenIds[index]);
        }
    }

    function initMint() private {
        for (uint256 index = 0; index < totalSupply; index++) {
            mint();
        }
    }

    function mint() private {
        remainingNFT.decrement();
        uint256 tokenId = totalSupply - remainingNFT.current();
        _mint(msg.sender, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract GoldNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private nftCounter;
    uint256 constant private MAX_TOKEN_ID = 99;
    uint256 public ntfPrice = 50000 wei;
    string private baseURI;
    mapping (uint256 => bool) private revealed;

    event RefundTransactionRecord(address indexed to, uint256 paidAmount, uint256 refundedAmount);

    constructor (string memory _baseURI) ERC721("GoldNFT", "GOLD") {
        _transferOwnership(msg.sender);
        baseURI = _baseURI;
    }

    function mint() public payable {
        require(msg.value >= ntfPrice, "Payment not enough!");
        uint256 currentNumber = nftCounter.current();

        require(currentNumber <= MAX_TOKEN_ID, "Token id out of range.");
        _safeMint(msg.sender, currentNumber);
        nftCounter.increment();

        if (msg.value > ntfPrice) {
            uint256 refundedAmount = msg.value - ntfPrice;
            payable(msg.sender).transfer(refundedAmount);
            emit RefundTransactionRecord(msg.sender, msg.value, refundedAmount);
        }
    }

    function switchRevealed(uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "You are not the owner.");
        revealed[tokenId] = true;
    }

    function setNftPrice(uint256 _nftPrice) public onlyOwner {
        ntfPrice = _nftPrice;
    }

    function withdrawEther() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        string memory path;

        if (revealed[tokenId]) {
            path = string.concat(tokenId.toString(), ".json");
        } else {
            path = "blind-box.json";
        }

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, path)) : "";
    }
}

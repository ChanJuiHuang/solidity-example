// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

struct PublicNFT {
    uint8 number;
    uint256 price;
}

abstract contract NFTStore {
    PublicNFT[] public publicNFTs;

    function initializeStore(uint256 publicNmuber) internal {
        setPublicRayNFTPrices(publicNmuber);
    }

    function setPublicRayNFTPrices(uint256 publicNmuber) private {
        for (uint8 index = 0; index < publicNmuber; index++) {
            PublicNFT memory publicNFT = PublicNFT({
                number: index,
                price: index * (1 wei)
            });
            publicNFTs.push(publicNFT);
        }
    }

    function getPublicNFTs() public view returns(PublicNFT[] memory) {
        return publicNFTs;
    }
}
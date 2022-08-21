// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "src/gold-nft/GoldNFT.sol";

contract ManipulateGoldNFT is Script {
    GoldNFT public goldNft;
    address public goldNftAddress = 0xfC5B9C925A634dd6393C4A053D18bAf4bbA4F263;

    function setUp() public {
        goldNft = GoldNFT(goldNftAddress);
    }

    function run() public {
        vm.broadcast();
        // (bool isSuccess,) = address(goldNft).call{value: 0.001 ether}(abi.encodeWithSignature("mint()"));

        // if (isSuccess) {
        //     console.log("Mint success!");
        // }

        goldNft.switchRevealed(0);
    }
}

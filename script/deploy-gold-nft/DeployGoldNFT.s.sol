// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "src/gold-nft/GoldNFT.sol";

contract DeployGoldNFT is Script {
    string baseURI = "https://gateway.pinata.cloud/ipfs/QmQcTza452auR9ZdF7PYHsau9hiGeLxwjsxfhXrLVjBM1o/";

    function run() public {
        vm.broadcast();
        new GoldNFT(baseURI);
    }
}

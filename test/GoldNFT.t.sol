// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/gold-nft/GoldNFT.sol";

contract GoldNFTTest is Test {
    using stdStorage for StdStorage;

    GoldNFT public goldNft;
    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    string public baseURI = "https://test.com/";

    function setUp() public {
        vm.startPrank(owner);
        goldNft = new GoldNFT(baseURI);
        vm.deal(owner, 100 ether);
    }

    function testOwner() public {
        assertEq(goldNft.owner(), owner);
    }

    function testMintSuccessfully() public {
        vm.recordLogs();
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertEq(isSuccess, true);
        assertEq(goldNft.ownerOf(0), owner);
        assertEq(goldNft.balanceOf(owner), 1);

        Vm.Log[] memory logEntries = vm.getRecordedLogs();
        uint256 lastIndex = logEntries.length - 1;
        (uint256 paidAmount, uint256 refundedAmount) = abi.decode(logEntries[lastIndex].data, (uint256, uint256));

        assertEq(logEntries[lastIndex].topics[0], keccak256("RefundTransactionRecord(address,uint256,uint256)"));
        assertEq(logEntries[lastIndex].topics[1], bytes32(uint256(uint160(owner))));
        assertEq(paidAmount, 1 ether);
        vm.assume(refundedAmount != 1 ether);
    }

    function testMintPaymentNotEnough() public {
        vm.expectRevert("Payment not enough!");
        (bool isSuccess,) = address(goldNft).call{value: 1 wei}(abi.encodeWithSignature("mint()"));
        assertTrue(isSuccess);
    }

    function testMintTokenIdOutOfRange() public {
        bool isSuccess = false;

        for (uint256 i = 0; i < 100; i++) {
            (isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        }
        vm.expectRevert("Token id out of range.");
        (isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertTrue(isSuccess);
    }

    function testSwitchRevealed() public {
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertEq(isSuccess, true);
        assertEq(string.concat(baseURI, "blind-box.json"), goldNft.tokenURI(0));
        goldNft.switchRevealed(0);
        assertEq(string.concat(baseURI, "0.json"), goldNft.tokenURI(0));
    }

    function testSetNftPrice() public {
        goldNft.setNftPrice(2 wei);
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertEq(isSuccess, true);

        vm.expectRevert("Payment not enough!");
        (isSuccess,) = address(goldNft).call{value: 1 wei}(abi.encodeWithSignature("mint()"));
        assertTrue(isSuccess);
    }

    function testSetNftPriceWithError() public {
        vm.stopPrank();
        vm.expectRevert("Ownable: caller is not the owner");
        goldNft.setNftPrice(2 wei);
    }

    function testWithdrawEther() public {
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertEq(isSuccess, true);
        vm.deal(owner, 0);
        goldNft.withdrawEther();
        vm.assume(address(owner).balance != 0);
    }

    function testWithdrawEtherWithError() public {
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        assertEq(isSuccess, true);
        vm.stopPrank();
        vm.expectRevert("Ownable: caller is not the owner");
        goldNft.withdrawEther();
    }

    function testSetBaseURI() public {
        (bool isSuccess,) = address(goldNft).call{value: 1 ether}(abi.encodeWithSignature("mint()"));
        string memory newBaseURI = "https://test2.com/";
        goldNft.setBaseURI(newBaseURI);
        assertEq(isSuccess, true);
        assertEq(string.concat(newBaseURI, "blind-box.json"), goldNft.tokenURI(0));
    }

    function testSetBaseURIWithError() public {
        vm.stopPrank();
        string memory newBaseURI = "https://test2.com/";
        vm.expectRevert("Ownable: caller is not the owner");
        goldNft.setBaseURI(newBaseURI);
    }
}

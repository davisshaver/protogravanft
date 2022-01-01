// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "./utils/ProtoGravaNFTTest.sol";
import {Defaults} from "../ProtoGravaNFT.sol";

contract ProtoGravNFTTestContract is ProtoGravaNFTTest {
    bytes32[] internal correctProof = [
        bytes32(
            0x4798ba4a7ba9f25bae47739561671bde97e24db5354942e12ac458f47e6029e2
        ),
        bytes32(
            0x181ac8d1f9b56849033a8f20b689480807306c64fb7e5d73d05ad24f3f35a181
        )
    ];
    bytes32[] internal incorrectProof = [
        bytes32(
            0xcdfbb9f337ecfd0bdabd6ff745888a67da3c90a38ec3737432e5fecdfe204881
        ),
        bytes32(
            0x181ac8d1f9b56849033a8f20b689480807306c64fb7e5d73d05ad24f3f35a181
        )
    ];
    string internal approvedGravatarHash = "00000000000000000000000000000000";
    string internal unApprovedGravatarHash = "11111111111111111111111111111111";
    address internal aliceAddress = 0x109F93893aF4C4b0afC7A9e97B59991260F98313;
    address internal bobAddress = 0x689856e2A6Eb68FC33099eb2CCBA0A5a4e8be52F;

    /// @notice Default description should be set in constructor
    function testDescriptionDefaultGet() public view {
        require(
            keccak256(abi.encodePacked(protogravanft.getDescription())) ==
                keccak256(abi.encodePacked(Defaults.DefaultDescription)),
            "Default description was not set correctly in constructor"
        );
    }

    /// @notice Default description should be updatable
    function testDescriptionSetAndGet() public {
        string memory newDescription = "New description";
        protogravanft.ownerSetDescription(newDescription);
        require(
            keccak256(abi.encodePacked(protogravanft.getDescription())) ==
                keccak256(abi.encodePacked(newDescription)),
            "Description is not set correctly when updated"
        );
    }

    /// @notice Default image format should be set in constructor
    function testDefaultFormatDefaultGet() public view {
        require(
            keccak256(
                abi.encodePacked(protogravanft.getDefaultImageFormat())
            ) == keccak256(abi.encodePacked(Defaults.DefaultForDefaultImage)),
            "Default image format was not set correctly in constructor"
        );
    }

    /// @notice Default image format should be updatable
    function testDefaultFormatSetAndGet() public {
        string memory newDefaultFormat = "retro";
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        require(
            keccak256(
                abi.encodePacked(protogravanft.getDefaultImageFormat())
            ) == keccak256(abi.encodePacked(newDefaultFormat)),
            "Image format is not set correctly when updated"
        );
    }

    /// @notice Owner should be set correctly
    function testLilOwnableOwner() public view {
        require(
            protogravanft.owner() == address(this),
            "Owner is not set correctly"
        );
    }

    /// @notice Owner should be able to transfer ownership
    function testLilOwnableOwnerTransfer() public {
        protogravanft.transferOwnership(address(alice));
        require(
            protogravanft.owner() == address(alice),
            "Owner is not transferred correctly"
        );
    }

    /// @notice Owner should be able to renounce ownership
    function testLilOwnableOwnerRenouncable() public {
        protogravanft.renounceOwnership();
        require(
            protogravanft.owner() == address(0),
            "Owner is not renounced correctly"
        );
    }

    /// @notice Sanity check for test addresses
    function testUserAddresses() public {
        assertEq(alice.getAddress(), aliceAddress);
        assertEq(bob.getAddress(), bobAddress);
    }

    /// @notice Allow Alice to mint a token for approved hash
    function testAliceMint() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint("Alice's Gravatar NFT", approvedGravatarHash, correctProof);
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
    }

    /// @notice Do not allow Alice to mint a token for unapproved hash
    function testFailAliceMintUnapproved() public {
        alice.mint(
            "Alice's Second Gravatar NFT",
            unApprovedGravatarHash,
            correctProof
        );
    }

    /// @notice Do not allow Alice to mint a token with wrong proof
    function testFailAliceMintWrongProof() public {
        alice.mint(
            "Alice's Second Gravatar NFT",
            approvedGravatarHash,
            incorrectProof
        );
    }

    /// @notice Do not allow Bob to mint any token
    function testFailBobMintUnapproved() public {
        bob.mint("Bob's Gravatar NFT", approvedGravatarHash, correctProof);
        bob.mint("Bob's Gravatar NFT", unApprovedGravatarHash, correctProof);
        bob.mint("Bob's Gravatar NFT", approvedGravatarHash, incorrectProof);
        bob.mint("Bob's Gravatar NFT", unApprovedGravatarHash, incorrectProof);
    }

    /// @notice Check whether minted token has right token URI
    function testAliceMintTokenURI() public {
        string memory aliceTokenName = "Alice's Gravatar NFT";
        alice.mint(aliceTokenName, approvedGravatarHash, correctProof);
        assertEq(
            protogravanft.tokenURI(1),
            formatTokenURI(approvedGravatarHash, aliceTokenName)
        );
    }

    /// @notice Ensure that token URI is updated after description change
    function testFailAliceMintTokenURIUpdatedDescriptionFormat() public {
        string memory aliceTokenName = "Alice's Gravatar NFT";
        alice.mint(aliceTokenName, approvedGravatarHash, correctProof);
        string memory aliceTokenURIPre = protogravanft.tokenURI(1);
        string memory newDefaultFormat = "retro";
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        string memory newDescription = "New description";
        protogravanft.ownerSetDescription(newDescription);
        string memory aliceTokenURIPost = protogravanft.tokenURI(1);
        assertEq(aliceTokenURIPre, aliceTokenURIPost);
    }
}

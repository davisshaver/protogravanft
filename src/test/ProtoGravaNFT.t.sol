// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "std/Vm.sol";
import "./utils/ProtoGravaNFTTest.sol";
import {Defaults} from "../ProtoGravaNFT.sol";

contract ProtoGravNFTTestContract is ProtoGravaNFTTest {
    Vm internal constant hevm = Vm(HEVM_ADDRESS);

    bytes32[] internal correctProofAlice = [
        bytes32(
            0x54e2ecd748a93255f36ec6059c92a2204fac8ad4888f945907913cfebd4d0071
        ),
        bytes32(
            0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23
        )
    ];
    bytes32[] internal incorrectProofBob = [
        bytes32(
            0x181ac8d1f9b56849033a8f20b689480807306c64fb7e5d73d05ad24f3f35a181
        ),
        bytes32(
            0x2d528cafebb0605a8001a946f37b368ac3811e2ff255460a9be71452a6ac24fe
        )
    ];
    bytes32[] internal correctProofCharlie = [
        bytes32(
            0xcdfbb9f337ecfd0bdabd6ff745888a67da3c90a38ec3737432e5fecdfe204881
        ),
        bytes32(
            0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23
        )
    ];
    string internal approvedGravatarHashAlice =
        "00000000000000000000000000000000";
    string internal unApprovedGravatarHashBob =
        "11111111111111111111111111111111";
    string internal approvedGravatarHashCharlie =
        "22222222222222222222222222222222";
    address internal aliceAddress = 0x109F93893aF4C4b0afC7A9e97B59991260F98313;
    address internal bobAddress = 0x689856e2A6Eb68FC33099eb2CCBA0A5a4e8be52F;
    address internal charlieAddress =
        0x2B0f159443599FBB6723CDB33d0DB94F96B95d0F;

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
        assertEq(charlie.getAddress(), charlieAddress);
    }

    /// @notice Allow Alice to mint a token for approved hash
    function testAliceMint() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint(
            "Alice's Gravatar NFT",
            approvedGravatarHashAlice,
            correctProofAlice
        );
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
    }

    /// @notice Ensure token ID increments correctly
    function testAliceCharlieMint() public {
        alice.mint(
            "Alice's Gravatar NFT",
            approvedGravatarHashAlice,
            correctProofAlice
        );
        charlie.mint(
            "Charlie's Gravatar NFT",
            approvedGravatarHashCharlie,
            correctProofCharlie
        );
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        assertEq(protogravanft.ownerOf(1), charlie.getAddress());
    }

    /// @notice Do not allow Alice to mint a token for unapproved hash
    function testAliceMintUnapproved() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        alice.mint(
            "Alice's Second Gravatar NFT",
            unApprovedGravatarHashBob,
            correctProofAlice
        );
    }

    /// @notice Do not allow Alice to mint a token with wrong proof
    function testAliceMintWrongProof() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        alice.mint(
            "Alice's Second Gravatar NFT",
            approvedGravatarHashAlice,
            incorrectProofBob
        );
    }

    /// @notice Do not allow Bob to mint any token
    function testBobMintUnapproved() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(
            "Bob's Gravatar NFT",
            approvedGravatarHashAlice,
            correctProofAlice
        );
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(
            "Bob's Gravatar NFT",
            unApprovedGravatarHashBob,
            correctProofAlice
        );
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(
            "Bob's Gravatar NFT",
            approvedGravatarHashAlice,
            incorrectProofBob
        );
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(
            "Bob's Gravatar NFT",
            unApprovedGravatarHashBob,
            incorrectProofBob
        );
    }

    /// @notice Check whether minted token has right token URI
    function testAliceMintTokenURI() public {
        string memory aliceTokenName = "Alice's Gravatar NFT";
        alice.mint(
            aliceTokenName,
            approvedGravatarHashAlice,
            correctProofAlice
        );
        assertEq(
            protogravanft.tokenURI(0),
            formatTokenURI(approvedGravatarHashAlice, aliceTokenName)
        );
    }

    /// @notice Ensure that token URI is updated after description change
    function testFailAliceMintTokenURIUpdatedDescriptionFormat() public {
        string memory aliceTokenName = "Alice's Gravatar NFT";
        alice.mint(
            aliceTokenName,
            approvedGravatarHashAlice,
            correctProofAlice
        );
        string memory aliceTokenURIPre = protogravanft.tokenURI(0);
        string memory newDefaultFormat = "retro";
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        string memory newDescription = "New description";
        protogravanft.ownerSetDescription(newDescription);
        string memory aliceTokenURIPost = protogravanft.tokenURI(0);
        assertEq(aliceTokenURIPre, aliceTokenURIPost);
    }

    /// @notice Ensure that total supply max cannot be exceeded
    function testMintWithMaxSupply() public {
        hevm.store(
            address(protogravanft),
            bytes32(uint256(7)),
            bytes32(protogravanft.TOTAL_SUPPLY())
        );
        assertEq(protogravanft.TOTAL_SUPPLY(), type(uint256).max - 1);
        hevm.expectRevert(abi.encodeWithSignature("NoTokensLeft()"));
        alice.mint(
            "Alice's Gravatar NFT",
            approvedGravatarHashAlice,
            correctProofAlice
        );
    }
}

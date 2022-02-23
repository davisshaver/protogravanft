// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "./utils/ProtoGravaNFTTest.sol";
import {Defaults} from "../ProtoGravaNFT.sol";

contract ProtoGravNFTTestContract is ProtoGravaNFTTest {
    Vm internal constant hevm = Vm(HEVM_ADDRESS);

    bytes32[] internal correctProofAlice = [
        bytes32(
            0x27a89e7e429a749efe6f0bb28e5b9454dc31d06efa093a771a811c6d0a30974f
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
            0xecbb993ddb51c658a2709dc4fb7eb5642159d30f9fa1fe8eae51af82b846d796
        )
    ];
    bytes32[] internal correctProofCharlie = [
        bytes32(
            0x705a8b4d085d439bfde84fe72ff1f879c9483c92176633d114e47022484b85ac
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
    address internal aliceAddress = 0x185a4dc360CE69bDCceE33b3784B0282f7961aea;
    address internal bobAddress = 0xEFc56627233b02eA95bAE7e19F648d7DcD5Bb132;
    address internal charlieAddress =
        0xf5a2fE45F4f1308502b1C136b9EF8af136141382;

    /// @notice Default description should be set in constructor
    function testDescriptionDefaultGet() public view {
        require(
            keccak256(abi.encodePacked(protogravanft.getDescription())) ==
                keccak256(abi.encodePacked(Defaults.DefaultDescription)),
            "Default description was not set correctly in constructor"
        );
    }

    /// @notice Default description should be updatable
    event DescriptionChanged(string newDescription);
    function testDescriptionSetAndGet() public {
        string memory newDescription = "New description";
        hevm.expectEmit(true, true, true, true);
        emit DescriptionChanged(newDescription);
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
    event DefaultFormatChanged(string newDefaultFormat);
    function testDefaultFormatSetAndGet() public {
        string memory newDefaultFormat = "retro";
        hevm.expectEmit(true, true, true, true);
        emit DefaultFormatChanged(newDefaultFormat);
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

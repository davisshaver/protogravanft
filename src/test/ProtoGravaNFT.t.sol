// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "base64-sol/base64.sol";
import {ProtoGravaNFTTest} from "./utils/ProtoGravaNFTTest.sol";
import {Defaults, Events} from "../ProtoGravaNFT.sol";

contract ProtoGravNFTTestContract is ProtoGravaNFTTest {
    address internal aliceAddress = 0x2e234DAe75C793f67A35089C9d99245E1C58470b;
    address internal bobAddress = 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a;
    address internal charlieAddress =
        0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;
    address internal chrisAddress = 0x3B60e31CFC48a9074CD5bEbb26C9EAa77650a43F;

    /// @notice Default description should be set in constructor
    function testDescriptionDefaultGet() public view {
        assertEq(
            keccak256(abi.encodePacked(protogravanft.getDescription())),
            keccak256(abi.encodePacked(Defaults.DEFAULT_DESCRIPTION))
        );
    }

    /// @notice Hacky function to test if what is contained in where
    /// @param what string to look for
    /// @param where string to check
    /// @return found or not
    function contains(
        string memory what,
        string memory where
    ) public pure returns (bool found) {
        bytes memory whatBytes = bytes(what);
        bytes memory whereBytes = bytes(where);
        found = false;
        if (whereBytes.length < whatBytes.length) {
            return found;
        }
        for (uint256 i = 0; i <= whereBytes.length - whatBytes.length; i++) {
            bool flag = true;
            for (uint256 j = 0; j < whatBytes.length; j++)
                if (whereBytes[i + j] != whatBytes[j]) {
                    flag = false;
                    break;
                }
            if (flag) {
                found = true;
                break;
            }
        }
        return found;
    }

    /// @notice Default description should be updatable only by owner
    function testDescriptionSetAndGet() public {
        string memory newDescription = "New description";
        vm.expectEmit(true, true, true, true);
        emit Events.DescriptionChanged(newDescription);
        protogravanft.ownerSetDescription(newDescription);
        assertEq(
            keccak256(abi.encodePacked(protogravanft.getDescription())),
            keccak256(abi.encodePacked(newDescription))
        );
        string memory anotherNewDescription = "Another new description";
        vm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        alice.ownerSetDescription(anotherNewDescription);
    }

    /// @notice Default image format should be set in constructor
    function testDefaultFormatDefaultGet() public view {
        assertEq(
            keccak256(abi.encodePacked(protogravanft.getDefaultImageFormat())),
            keccak256(abi.encodePacked(Defaults.DEFAULT_FOR_DEFAULT_IMAGE))
        );
    }

    /// @notice Default image format should be updatable
    function testDefaultFormatSetAndGet() public {
        string memory newDefaultFormat = "retro";
        vm.expectEmit(true, true, true, true);
        emit Events.DefaultFormatChanged(newDefaultFormat);
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        assertEq(
            keccak256(abi.encodePacked(protogravanft.getDefaultImageFormat())),
            keccak256(abi.encodePacked(newDefaultFormat))
        );
    }

    /// @notice Owner should be set correctly
    function testLilOwnableOwner() public view {
        assertEq(protogravanft.owner(), address(this));
    }

    /// @notice Owner should be able to transfer ownership
    function testLilOwnableOwnerTransfer() public {
        protogravanft.transferOwnership(address(alice));
        assertEq(protogravanft.owner(), address(alice));
    }

    /// @notice Owner should be able to renounce ownership
    function testLilOwnableOwnerRenouncable() public {
        protogravanft.renounceOwnership();
        assertEq(protogravanft.owner(), address(0));
    }

    /// @notice Sanity check for test addresses
    function testUserAddresses() public view {
        assertEq(alice.getAddress(), aliceAddress);
        assertEq(bob.getAddress(), bobAddress);
        assertEq(charlie.getAddress(), charlieAddress);
    }

    /// @notice Test that public minting is enabled by default
    function testPublicMintDisabled() public view {
        assertTrue(protogravanft.isPublicMintEnabled());
    }

    /// @notice Test that public minting can be disabled
    function testPublicMintToggle() public {
        protogravanft.ownerTogglePublicMint();
        assertTrue(!protogravanft.isPublicMintEnabled());
        vm.expectRevert(abi.encodeWithSignature("PublicMintDisabled()"));
        alice.mint();
        protogravanft.mint();
        assertEq(protogravanft.balanceOf(address(this)), 1);
    }

    /// @notice Allow Alice to mint a token for approved hash
    function testAliceMint() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint();
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
        vm.expectRevert(abi.encodeWithSignature("OnePerUser()"));
        alice.mint();
        charlie.mint();
        assertEq(protogravanft.ownerOf(2), charlie.getAddress());
        vm.expectRevert(abi.encodeWithSignature("OnePerUser()"));
        charlie.transferFrom(aliceAddress, 1);
    }

    /// @notice Allow Alice to mint a token and transfer it to Charlie
    function testAliceMintAndTransferLimitReach() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint();
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
        alice.transferFrom(charlieAddress, 1);
        assertEq(protogravanft.ownerOf(1), charlie.getAddress());
    }

    /// @notice Allow Alice to mint a token for approved hash and then burn it
    function testAliceMintAndBurn() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint();
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
        vm.expectRevert(abi.encodeWithSignature("NotAllowedToBurn()"));
        charlie.burn(1);
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
        assertEq(protogravanft.totalSupply(), 1);
        alice.burn(1);
        vm.expectRevert(bytes("NOT_MINTED"));
        assertEq(protogravanft.ownerOf(1), address(0));
        assertEq(alice.tokenBalance(), 0);
        assertEq(protogravanft.totalSupply(), 0);
    }

    /// @notice Ensure token ID increments correctly
    function testAliceCharlieMint() public {
        alice.mint();
        charlie.mint();
        assertEq(protogravanft.ownerOf(1), alice.getAddress());
        assertEq(protogravanft.ownerOf(2), charlie.getAddress());
    }

    /// @notice Ensure that token URI is updated after description change
    function testFailAliceMintTokenURIUpdatedDescriptionFormat() public {
        alice.mint();
        string memory aliceTokenURIPre = protogravanft.tokenURI(0);
        string memory newDefaultFormat = "retro";
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        string memory newDescription = "New description";
        protogravanft.ownerSetDescription(newDescription);
        string memory aliceTokenURIPost = protogravanft.tokenURI(0);
        assertEq(aliceTokenURIPre, aliceTokenURIPost);
    }

    /// @notice Ensure that we can hash an email address and get the expected result
    function testHashEmail() public view {
        assertEq(
            protogravanft.hashNormalizedString("davisshaver@gmail.com"),
            "599d7678a2ae568980365f733917d796443920f39fab95dc8a590618ddf6fe8f"
        );
    }

    /* solhint-disable quotes */
    /// @notice Check for expected ENS attributes after transfer
    function testAliceMintTransferENSAttributes() public {
        alice.mint();
        (
            string memory aliceTokenNamePre,
            bool aliceTokenHasEnsPre
        ) = protogravanft.getTokenName(1);
        string memory aliceAddressString = Strings.toHexString(
            uint256(uint160(alice.getAddress())),
            20
        );
        assertEq(aliceTokenNamePre, aliceAddressString);
        assertTrue(!aliceTokenHasEnsPre);
        alice.transferFrom(
            address(0x0F9Bd2a9E0D30f121c525DB5419A07b08Fce8440),
            1
        );
        (
            string memory aliceTokenNamePost,
            bool aliceTokenHasEnsPost
        ) = protogravanft.getTokenName(1);
        string memory aliceTokenBase64Post = protogravanft
            .generateTokenURIBase64(1);
        assertTrue(aliceTokenHasEnsPost);
        bytes memory aliceTokenURIPostDecoded = Base64.decode(
            aliceTokenBase64Post
        );
        assertTrue(
            contains(
                "davisshaver.eth",
                abi.decode(
                    vm.parseJson(string(aliceTokenURIPostDecoded), ".name"),
                    (string)
                )
            )
        );
        assertTrue(
            contains(
                '"name": "davisshaver.eth",',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Location", "value": "Lebanon Valley"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Email", "value": "davisshaver@gmail.com"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Github", "value": "davisshaver"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "URL", "value": "https://davisshaver.com"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Twitter", "value": "davisshaver"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Discord", "value": "davisshaver"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertTrue(
            contains(
                '"trait_type": "Telegram", "value": "davisshaver"',
                string(aliceTokenURIPostDecoded)
            )
        );
        assertEq(aliceTokenNamePost, "davisshaver.eth");
    }

    /* solhint-enable quotes */

    /// @notice Ensure that total supply max cannot be exceeded
    function testMintWithMaxSupply() public {
        // @TODO Add some documentation here, magical storage slot number.
        vm.store(
            address(protogravanft),
            bytes32(uint256(7)),
            bytes32(protogravanft.MAX_TOTAL_MINTED())
        );
        assertEq(protogravanft.MAX_TOTAL_MINTED(), type(uint256).max - 1);
        vm.expectRevert(abi.encodeWithSignature("NoTokensLeft()"));
        alice.mint();
    }

    /// @notice Ensure that expected errors are thrown if ID does not have email or ENS
    function testNoEmailOrENS() public {
        bob.mint();
        assertEq(protogravanft.ownerOf(1), bob.getAddress());
        vm.expectRevert(abi.encodeWithSignature("NoENSName()"));
        protogravanft.tokenURI(1);
        charlie.mint();
        charlie.transferFrom(
            address(0x3B60e31CFC48a9074CD5bEbb26C9EAa77650a43F),
            2
        );
        assertEq(
            protogravanft.ownerOf(2),
            0x3B60e31CFC48a9074CD5bEbb26C9EAa77650a43F
        );
        vm.expectRevert(abi.encodeWithSignature("NoENSEmailTextRecord()"));
        protogravanft.tokenURI(2);
    }

    /// @notice Ensure that expected errors are thrown if ID does not exist
    function testWithFuzzing(uint256 fuzzId) public {
        vm.expectRevert(abi.encodeWithSignature("DoesNotExist()"));
        protogravanft.tokenURI(fuzzId);
        vm.expectRevert(abi.encodeWithSignature("DoesNotExist()"));
        protogravanft.generateTokenURIBase64(fuzzId);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "./utils/ProtoGravaNFTTest.sol";
import {Defaults, Events} from "../ProtoGravaNFT.sol";

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

    /// @notice Hacky function to test if what is contained in where
    /// @param what string to look for
    /// @param where string to check
    /// @return found or not
    function contains(string memory what, string memory where)
        public
        pure
        returns (bool found)
    {
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

    /// @notice Basic integer from address test. (Currently WIP.)
    function testIntegerFromAddress() public pure {
        require(uint256(uint160(address(0))) == 0, "Integer from address");
    }

    /// @notice Integer from address test for VB. (Currently WIP.)
    function testIntegerFromAddressVB() public pure {
        require(
            uint256(
                uint160(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B))
            ) == 978200031609045874420567273872976536139233684635,
            "Integer from address"
        );
    }

    /// @notice Default description should be updatable
    function testDescriptionSetAndGet() public {
        string memory newDescription = "New description";
        hevm.expectEmit(true, true, true, true);
        emit Events.DescriptionChanged(newDescription);
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
        hevm.expectEmit(true, true, true, true);
        emit Events.DefaultFormatChanged(newDefaultFormat);
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
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 0);
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
    }

    /// @notice Allow Alice to mint a token for approved hash but not to transfer
    function testAliceMintAndTransferLimitReach() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 0);
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        hevm.expectRevert(abi.encodeWithSignature("TransferLimitReached()"));
        alice.transferFrom(charlieAddress, 0);
    }

    /// @notice Allow Alice to mint a token for approved hash and transfer once, not twice
    function testAliceMintAndTransferOnceBeforeLimitReached() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 1);
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        alice.transferFrom(charlieAddress, 0);
        assertEq(protogravanft.ownerOf(0), charlie.getAddress());
        hevm.expectRevert(abi.encodeWithSignature("TransferLimitReached()"));
        charlie.transferFrom(aliceAddress, 0);
    }

    /// @notice Allow Alice to mint a token for approved hash and then burn it
    function testAliceMintAndBurn() public {
        // Collect Alice balance of tokens before mint
        uint256 alicePreBalance = alice.tokenBalance();
        // Mint approved token
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 1);
        // Collect Alice balance of tokens after mint
        uint256 alicePostBalance = alice.tokenBalance();
        assertEq(alicePreBalance, 0);
        assertEq(alicePostBalance, 1);
        assertEq(protogravanft.totalSupply(), 1);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        hevm.expectRevert(abi.encodeWithSignature("NotAllowedToBurn()"));
        charlie.burn(0);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        alice.burn(0);
        hevm.expectRevert(bytes("NOT_MINTED"));
        assertEq(protogravanft.ownerOf(0), address(0));
        assertEq(alice.tokenBalance(), 0);
    }

    /// @notice Ensure token ID increments correctly
    function testAliceCharlieMint() public {
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 0);
        charlie.mint(approvedGravatarHashCharlie, correctProofCharlie, 0);
        assertEq(protogravanft.ownerOf(0), alice.getAddress());
        assertEq(protogravanft.ownerOf(1), charlie.getAddress());
    }

    /// @notice Do not allow Alice to mint a token for unapproved hash
    function testAliceMintUnapproved() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        alice.mint(unApprovedGravatarHashBob, correctProofAlice, 0);
    }

    /// @notice Do not allow Alice to mint a token with wrong proof
    function testAliceMintWrongProof() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        alice.mint(approvedGravatarHashAlice, incorrectProofBob, 0);
    }

    /// @notice Do not allow Bob to mint any token
    function testBobMintUnapproved() public {
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(approvedGravatarHashAlice, correctProofAlice, 0);
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(unApprovedGravatarHashBob, correctProofAlice, 0);
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(approvedGravatarHashAlice, incorrectProofBob, 0);
        hevm.expectRevert(abi.encodeWithSignature("NotInMerkle()"));
        bob.mint(unApprovedGravatarHashBob, incorrectProofBob, 0);
    }

    /// @notice Ensure that token URI is updated after description change
    function testFailAliceMintTokenURIUpdatedDescriptionFormat() public {
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 0);
        string memory aliceTokenURIPre = protogravanft.tokenURI(0);
        string memory newDefaultFormat = "retro";
        protogravanft.ownerSetDefaultFormat(newDefaultFormat);
        string memory newDescription = "New description";
        protogravanft.ownerSetDescription(newDescription);
        string memory aliceTokenURIPost = protogravanft.tokenURI(0);
        assertEq(aliceTokenURIPre, aliceTokenURIPost);
    }

    /* solhint-disable quotes */
    /// @notice Check for expected ENS attributes after transfer
    function testAliceMintTransferENSAttributes() public {
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 1);
        (
            string memory aliceTokenNamePre,
            bool aliceTokenHasEnsPre
        ) = protogravanft.getTokenName(0);
        string memory aliceAddressString = Strings.toHexString(
            uint256(uint160(alice.getAddress())),
            20
        );
        assertEq(aliceTokenNamePre, aliceAddressString);
        assertTrue(!aliceTokenHasEnsPre);
        alice.transferFrom(
            address(0xaf045Cb0dBC1225948482e4692Ec9dC7Bb3cD48b),
            0
        );
        (
            string memory aliceTokenNamePost,
            bool aliceTokenHasEnsPost
        ) = protogravanft.getTokenName(0);
        string memory aliceTokenBase64Post = protogravanft
            .generateTokenURIBase64(0);
        assertTrue(aliceTokenHasEnsPost);
        bytes memory aliceTokenURIPostDecoded = Base64.decode(
            aliceTokenBase64Post
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
                '"trait_type": "URL", "value": "https://davisshaver.com/"',
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
                '"trait_type": "Discord", "value": "davisshaver#4551"',
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
        hevm.store(
            address(protogravanft),
            bytes32(uint256(9)),
            bytes32(protogravanft.MAX_TOTAL_SUPPLY())
        );
        assertEq(protogravanft.MAX_TOTAL_SUPPLY(), type(uint256).max - 1);
        hevm.expectRevert(abi.encodeWithSignature("NoTokensLeft()"));
        alice.mint(approvedGravatarHashAlice, correctProofAlice, 0);
    }

    /// @notice Ensure that expected errors are thrown if ID does not exist
    function testWithFuzzing(uint256 fuzzId) public {
        hevm.expectRevert(abi.encodeWithSignature("DoesNotExist()"));
        protogravanft.tokenURI(fuzzId);
        hevm.expectRevert(abi.encodeWithSignature("DoesNotExist()"));
        protogravanft.generateTokenURIBase64(fuzzId);
    }
}

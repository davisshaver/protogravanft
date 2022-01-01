// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "./utils/ProtoGravaNFTTest.sol";
import {Defaults} from "../ProtoGravaNFT.sol";

contract ProtoGravNFTTestContract is ProtoGravaNFTTest {
    bytes32[] internal proof = [
        bytes32(
            0x4798ba4a7ba9f25bae47739561671bde97e24db5354942e12ac458f47e6029e2
        ),
        bytes32(
            0x181ac8d1f9b56849033a8f20b689480807306c64fb7e5d73d05ad24f3f35a181
        )
    ];
    string internal gravatarHashOne = "60f9fcb4b3cc5e3add081dd95d4a3705";
    string internal gravatarHashTwo = "TK";

    function testGetDescription() public view {
        require(
            keccak256(abi.encodePacked(protogravanft.getDescription())) ==
                keccak256(abi.encodePacked(Defaults.DefaultDescription)),
            "Description is not set correctly"
        );
    }

    function testGetDefaultForDefaultImage() public view {
        require(
            keccak256(
                abi.encodePacked(protogravanft.getDefaultImageFormat())
            ) == keccak256(abi.encodePacked(Defaults.DefaultForDefaultImage)),
            "Default image format is not set correctly"
        );
    }

    function testNonOwnerCannotUseOwnerMint() public {
        try bob.ownerMint(gravatarHashOne) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "Ownable: caller is not the owner");
        }
    }

    function testOwnerCanUseOwnerMintButOnlyOnce() public {
        require(
            alice.ownerMint(gravatarHashOne) == 1,
            "Owner should receive first token upon first mint"
        );
        require(
            protogravanft.ownerOf(1) == alice.getAddress(),
            "Token owner does not match expected address"
        );
        require(
            keccak256(abi.encodePacked(protogravanft.tokenURI(1))) ==
                keccak256(
                    abi.encodePacked(
                        protogravanft.formatTokenURI(
                            gravatarHashOne,
                            gravatarHashOne,
                            Defaults.DefaultDescription,
                            Defaults.DefaultForDefaultImage
                        )
                    )
                ),
            "Token URI does not match expected output"
        );
        try alice.ownerMint(gravatarHashOne) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, Errors.ErrorHashAlreadyUsed);
        }
    }

    function testAllowlistAddressCanUsePublicMintForOwnHashOnly() public {
        try bob.publicMint(gravatarHashOne, proof) {
            fail();
        } catch Error(string memory error) {
            assertEq(error, Errors.ErrorUnauthorizedHash);
        }
        require(
            bob.publicMint(gravatarHashTwo, proof) == 1,
            "Allowlisted user should receive a token"
        );
    }
}

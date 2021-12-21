// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../GravaNFT.sol";

contract GravatarsTest is DSTest {
    GravaNFT public gravanft;

    function setUp() public {
        gravanft = new GravaNFT();
    }

    function testClaimGravatar() public {
        address gravatarMinter = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
        string memory gravatarHash = "205e460b479e2e5b48aec07710c08d50";
        require(gravanft.mintGravatar(gravatarMinter, gravatarHash) == 1);
        require(gravanft.ownerOf(1) == gravatarMinter);
        require(
            keccak256(abi.encodePacked(gravanft.tokenURI(1))) ==
                keccak256(
                    abi.encodePacked(
                        string(
                            abi.encodePacked(
                                "data:application/json;base64,",
                                Base64.encode(
                                    abi.encodePacked(
                                        bytes(
                                            abi.encodePacked(
                                                "{'name':'",
                                                gravatarHash,
                                                "', 'description': '",
                                                gravatarHash,
                                                "', 'attributes': '', 'image': 'https://secure.gravatar.com/avatar/",
                                                gravatarHash,
                                                "?s=2048'}"
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

import {LilENSTest} from "./utils/LilENSTest.sol";

contract LilENSTestContract is LilENSTest {
    /// @notice Address to ENS lookup (Vitalik)
    function testAddrToENSVitalik() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
                    )[0]
                )
            ),
            keccak256(abi.encodePacked("vitalik.eth"))
        );
    }

    /// @notice Address to ENS lookup
    function testAddrToENS() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0x0F9Bd2a9E0D30f121c525DB5419A07b08Fce8440
                    )[0]
                )
            ),
            keccak256(abi.encodePacked("davisshaver.eth"))
        );
    }

    /// @notice Address to ENS lookup, with no ENS set
    function testAddrToNoENS() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0x2f683A6B50aCd85edf0bbc612eB34b982cFc1b32
                    )[0]
                )
            ),
            keccak256(abi.encodePacked(""))
        );
    }

    /// @notice Test get resolver for a given namehash
    function testGetResolver() public view {
        // Namehash of davisshaver.eth.
        bytes32 testNameHash = 0x83e599a723b25a15ed6a3b6f4957b094beae097bbbe1c3a205208a67d3cf9063;
        // Known resolver of davisshaver.eth.
        address expectedResolver = 0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63;
        assertEq(address(enstest.getResolver(testNameHash)), expectedResolver);
    }

    /// @notice Test get resolver for a given namehash, where namehash is not registered
    function testGetResolverUnknownName() public view {
        // Namehash of shaverdavis.eth.
        bytes32 testNameHash = 0xc672ad32780a650e216bd6ddedea4e3589de1f51562062087d20ab3892754fa5;
        // No resolver should come back.
        address expectedResolver = address(0);
        assertEq(address(enstest.getResolver(testNameHash)), expectedResolver);
    }

    /// @notice ENS to address lookup
    function testENSToAddr() public view {
        assertEq(
            enstest.ensToAddr("davisshaver.eth"),
            0x0F9Bd2a9E0D30f121c525DB5419A07b08Fce8440
        );
    }

    /// @notice ENS to address lookup, with name not claimed
    function testENSToAddrNoENS() public view {
        assertEq(enstest.ensToAddr("shaverdavis.eth"), address(0));
    }

    /// @notice ENS to text lookup (location)
    function testENSToTextLocation() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "location")
                )
            ),
            keccak256(abi.encodePacked("Lebanon Valley"))
        );
    }

    /// @notice ENS to text lookup, missing record (cellphone)
    function testENSToTextMissingRecord() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "cellphone")
                )
            ),
            keccak256(abi.encodePacked(""))
        );
    }

    /// @notice ENS to text lookup (Github)
    function testENSToTextGithub() public view {
        assertEq(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "com.github")
                )
            ),
            keccak256(abi.encodePacked("davisshaver"))
        );
    }

    /// @notice ENS to text lookup (email)
    function testENSToTextEmail() public view {
        assertEq(
            keccak256(
                abi.encodePacked(enstest.ensToText("ccarella.eth", "email"))
            ),
            keccak256(abi.encodePacked(""))
        );
    }
}

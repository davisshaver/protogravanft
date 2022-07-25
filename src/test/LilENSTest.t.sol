// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "./utils/LilENSTest.sol";

contract LilENSTestContract is LilENSTest {
    Vm internal constant hevm = Vm(HEVM_ADDRESS);

    /// @notice Address to ENS lookup (Vitalik)
    function testAddrToENSVitalik() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
                    )[0]
                )
            ) == keccak256(abi.encodePacked("vitalik.eth")),
            "Address to ENS lookup failed"
        );
    }

    /// @notice Address to ENS lookup
    function testAddrToENS() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0xaf045Cb0dBC1225948482e4692Ec9dC7Bb3cD48b
                    )[0]
                )
            ) == keccak256(abi.encodePacked("davisshaver.eth")),
            "Address to ENS lookup failed"
        );
    }

    /// @notice Address to ENS lookup, with no ENS set
    function testAddrToNoENS() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.addrToENS(
                        0x2f683A6B50aCd85edf0bbc612eB34b982cFc1b32
                    )[0]
                )
            ) == keccak256(abi.encodePacked("")),
            "Address to ENS lookup failed"
        );
    }

    /// @notice Test get resolver for a given namehash
    function testGetResolver() public view {
        // Namehash of davisshaver.eth.
        bytes32 testNameHash = 0x83e599a723b25a15ed6a3b6f4957b094beae097bbbe1c3a205208a67d3cf9063;
        // Known resolver of davisshaver.eth.
        address expectedResolver = 0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41;
        require(
            address(enstest.getResolver(testNameHash)) == expectedResolver,
            "Resolver lookup failed"
        );
    }

    /// @notice Test get resolver for a given namehash, where namehash is not registered
    function testGetResolverUnknownName() public view {
        // Namehash of shaverdavis.eth.
        bytes32 testNameHash = 0xc672ad32780a650e216bd6ddedea4e3589de1f51562062087d20ab3892754fa5;
        // No resolver should come back.
        address expectedResolver = address(0);
        require(
            address(enstest.getResolver(testNameHash)) == expectedResolver,
            "Resolver lookup failed"
        );
    }

    /// @notice ENS to address lookup
    function testENSToAddr() public view {
        require(
            enstest.ensToAddr("davisshaver.eth") ==
                0xaf045Cb0dBC1225948482e4692Ec9dC7Bb3cD48b,
            "ENS to address lookup failed"
        );
    }

    /// @notice ENS to address lookup, with name not claimed
    function testENSToAddrNoENS() public view {
        require(
            enstest.ensToAddr("shaverdavis.eth") == address(0),
            "ENS to address lookup failed"
        );
    }

    /// @notice ENS to text lookup (location)
    function testENSToTextLocation() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "location")
                )
            ) == keccak256(abi.encodePacked("Lebanon Valley")),
            "ENS to text record lookup failed"
        );
    }

    /// @notice ENS to text lookup, missing record (cellphone)
    function testENSToTextMissingRecord() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "cellphone")
                )
            ) == keccak256(abi.encodePacked("")),
            "ENS to text record lookup failed"
        );
    }

    /// @notice ENS to text lookup (Github)
    function testENSToTextGithub() public view {
        require(
            keccak256(
                abi.encodePacked(
                    enstest.ensToText("davisshaver.eth", "com.github")
                )
            ) == keccak256(abi.encodePacked("davisshaver")),
            "ENS to text record lookup failed"
        );
    }
}

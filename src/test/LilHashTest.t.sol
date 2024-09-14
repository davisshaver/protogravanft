// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

import {LilHashTest} from "./utils/LilHashTest.sol";

contract LilHashTestContract is LilHashTest {
    /// @notice Test trim function
    function testTrim() public view {
        string memory testString = "  davisshaver@gmail.com  ";
        string memory expectedString = "davisshaver@gmail.com";
        assertEq(
            keccak256(abi.encodePacked(hashtest.trim(testString))),
            keccak256(abi.encodePacked(expectedString))
        );
    }

    /// @notice Test toLowerCase function
    function testToLowerCase() public view {
        string memory testString = "DAVISSHAVER@GMAIL.COM";
        string memory expectedString = "davisshaver@gmail.com";
        assertEq(
            keccak256(abi.encodePacked(hashtest.toLowerCase(testString))),
            keccak256(abi.encodePacked(expectedString))
        );
    }

    /// @notice Test hashString function
    function testHashString() public view {
        string memory testString = "davisshaver@gmail.com";
        bytes32 expectedHash = bytes32(
            0x599D7678A2AE568980365F733917D796443920F39FAB95DC8A590618DDF6FE8F
        );
        assertEq(hashtest.hashString(testString), expectedHash);
    }

    /// @notice Test hashNormalizedString function
    function testHashNormalizedString() public view {
        string memory testString = "   DAVISSHAVER@gmail.com    ";
        string
            memory expectedHash = "599d7678a2ae568980365f733917d796443920f39fab95dc8a590618ddf6fe8f";
        assertEq(
            keccak256(
                abi.encodePacked(hashtest.hashNormalizedString(testString))
            ),
            keccak256(abi.encodePacked(expectedHash))
        );
    }
}

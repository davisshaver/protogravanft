// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "./utils/LilHashTest.sol";

contract LilHashTestContract is LilHashTest {
    Vm internal constant hevm = Vm(HEVM_ADDRESS);

    /// @notice Test trim function
    function testTrim() public view {
        string memory testString = "  davisshaver@gmail.com  ";
        string memory expectedString = "davisshaver@gmail.com";
        require(
            keccak256(abi.encodePacked(hashtest.trim(testString))) ==
                keccak256(abi.encodePacked(expectedString)),
            "Trim failed"
        );
    }

    /// @notice Test toLowerCase function
    function testToLowerCase() public view {
        string memory testString = "DAVISSHAVER@GMAIL.COM";
        string memory expectedString = "davisshaver@gmail.com";
        require(
            keccak256(abi.encodePacked(hashtest.toLowerCase(testString))) ==
                keccak256(abi.encodePacked(expectedString)),
            "Lower casing failed"
        );
    }

    /// @notice Test hashString function
    function testHashString() public view {
        string memory testString = "davisshaver@gmail.com";
        bytes32 expectedHash = bytes32(
            0x599D7678A2AE568980365F733917D796443920F39FAB95DC8A590618DDF6FE8F
        );
        require(
            hashtest.hashString(testString) == expectedHash,
            "Hashing failed"
        );
    }

    /// @notice Test hashNormalizedString function
    function testHashNormalizedString() public view {
        string memory testString = "   DAVISSHAVER@gmail.com    ";
        string
            memory expectedHash = "599d7678a2ae568980365f733917d796443920f39fab95dc8a590618ddf6fe8f";
        require(
            keccak256(
                abi.encodePacked(hashtest.hashNormalizedString(testString))
            ) == keccak256(abi.encodePacked(expectedHash)),
            "Hashing failed"
        );
    }
}

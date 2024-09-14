// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/// @title LilHash
/// @notice Lil' helper library for normalizing and hashing strings
/// @author Davis Shaver <davisshaver@gmail.com>
abstract contract LilHash {
    /// @notice Normalizes and hashes string
    /// @param stringToHash String to hash
    /// @return Hashed string
    function hashNormalizedString(
        string memory stringToHash
    ) public pure returns (string memory) {
        return toHexString(hashString(trim(toLowerCase(stringToHash))));
    }

    /// @notice Trims whitespace from both ends of string
    /// @param str String to trim
    /// @return Trimmed string
    function trim(string memory str) public pure returns (string memory) {
        uint256 i = 0;
        bytes memory strBytes = bytes(str);
        while (i < strBytes.length && strBytes[i] == 0x20) {
            i++;
        }

        uint256 j = strBytes.length - 1;
        while (j > i && strBytes[j] == 0x20) {
            j--;
        }

        bytes memory trimmed = new bytes(j - i + 1);
        for (uint256 k = 0; k <= j - i; k++) {
            trimmed[k] = strBytes[k + i];
        }

        return string(trimmed);
    }

    /// @notice Converts all characters in string to lowercase
    /// @param str String to convert
    /// @return Lowercase string
    function toLowerCase(
        string memory str
    ) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);

        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character ASCII range
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // Convert to lower case
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }

        return string(bLower);
    }

    /// @notice Hashes string
    /// @param input String to hash
    /// @return Hashed string
    function hashString(string memory input) public pure returns (bytes32) {
        return sha256(abi.encodePacked(input));
    }

    /// @notice Converts bytes32 to string
    /// @param _bytes32 bytes32 to convert
    /// @return Converted string
    function bytes32ToString(
        bytes32 _bytes32
    ) public pure returns (string memory) {
        return string(abi.encodePacked(_bytes32));
    }

    /// @notice Converts bytes32 to hex string
    /// @param data bytes32 to convert
    /// @return Converted string
    function toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i * 2] = alphabet[uint8(data[i] >> 4)];
            str[1 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

/// @title Strings
/// @notice Adapted from https://github.com/ensdomains/reverse-records/blob/master/contracts/Namehash.sol
library NamehashStrings {
    struct Slice {
        uint256 _len;
        uint256 _ptr;
    }

    /// @notice Returns a slice containing the entire string
    /// @param self The string to make a slice from
    /// @return A newly allocated slice containing the entire string
    function toSlice(string memory self) internal pure returns (Slice memory) {
        uint256 ptr;
        /* solhint-disable no-inline-assembly */
        assembly {
            ptr := add(self, 0x20)
        }
        /* solhint-enable no-inline-assembly */
        return Slice(bytes(self).length, ptr);
    }

    /// @notice Returns the keccak-256 hash of the slice
    /// @param self The slice to hash
    /// @return ret The hash of the slice
    function keccak(Slice memory self) internal pure returns (bytes32 ret) {
        /* solhint-disable no-inline-assembly */
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
        /* solhint-enable no-inline-assembly */
    }

    /// @notice Returns true if the slice is empty (has a length of 0)
    /// @param self The slice to operate on
    /// @return True if the slice is empty, false otherwise
    function empty(Slice memory self) internal pure returns (bool) {
        return self._len == 0;
    }

    /// @notice Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found
    /// @param selflen Length of string
    /// @param selfptr Size of string
    /// @param needlelen Length of needle
    /// @param needleptr Size of needle
    function rfindPtr(
        uint256 selflen,
        uint256 selfptr,
        uint256 needlelen,
        uint256 needleptr
    ) private pure returns (uint256) {
        uint256 ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2**(8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                /* solhint-disable no-inline-assembly */
                assembly {
                    needledata := and(mload(needleptr), mask)
                }
                /* solhint-enable no-inline-assembly */

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                /* solhint-disable no-inline-assembly */
                assembly {
                    ptrdata := and(mload(ptr), mask)
                }
                /* solhint-enable no-inline-assembly */

                while (ptrdata != needledata) {
                    if (ptr <= selfptr) return selfptr;
                    ptr--;
                    /* solhint-disable no-inline-assembly */
                    assembly {
                        ptrdata := and(mload(ptr), mask)
                    }
                }
                /* solhint-enable no-inline-assembly */
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                /* solhint-disable no-inline-assembly */
                assembly {
                    hash := keccak256(needleptr, needlelen)
                }
                /* solhint-enable no-inline-assembly */
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    /* solhint-disable no-inline-assembly */
                    assembly {
                        testHash := keccak256(ptr, needlelen)
                    }
                    /* solhint-enable no-inline-assembly */
                    if (hash == testHash) return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /// @notice Splits the slice, setting `self` to everything before the last occurrence of `needle`,
    // and `token` to everything after it. If `needle` does not occur in `self`, `self` is set to the
    // empty slice, and `token` is set to the entirety of `self`.
    /// @param self The slice to split
    /// @param needle The text to search for in 'self'
    /// @param token An output parameter to which the first token is written
    /// @return Token
    function rsplit(
        Slice memory self,
        Slice memory needle,
        Slice memory token
    ) internal pure returns (Slice memory) {
        uint256 ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }
}

/// @title Namehash
/// @notice Adapted from https://github.com/ensdomains/reverse-records/blob/master/contracts/Namehash.sol
library Namehash {
    using NamehashStrings for *;

    /// @notice Get namehash for name
    /// @param name Name to check
    /// @return hash Generated namehash
    function namehash(string memory name) internal pure returns (bytes32 hash) {
        hash = bytes32(0);
        NamehashStrings.Slice memory nameslice = name.toSlice();
        NamehashStrings.Slice memory delim = ".".toSlice();
        NamehashStrings.Slice memory token;
        for (
            nameslice.rsplit(delim, token);
            !token.empty();
            nameslice.rsplit(delim, token)
        ) {
            hash = keccak256(abi.encodePacked(hash, token.keccak()));
        }
        return hash;
    }
}

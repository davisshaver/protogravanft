// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

/// ============ Internal Imports ============

import "./Namehash.sol";

/// @title LilENS
/// @notice Lil' helper library for getting info from ENS
/// @author Davis Shaver <davisshaver@gmail.com>
abstract contract LilENS {
    /// ============ Mutable Storage ============

    /// @notice Reverse records contract address
    // @todo Make this configurable for different networks
    address public ensReverseContractLookupAddress =
        address(0x3671aE578E63FdF66ad4F3E12CC0c0d71Ac7510C);

    /// @notice ENS registry contract
    ENS public ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    /// @notice Find ENS names for a given address
    /// @param addr to lookup
    /// @return ENS names
    function addrToENS(address addr) public view returns (string[] memory) {
        ReverseRecords reverseRecords = ReverseRecords(
            ensReverseContractLookupAddress
        );
        address[] memory t = new address[](1); // Define a fixed length array for getNames lookup.
        t[0] = addr;
        return reverseRecords.getNames(t);
    }

    /// @notice Find address for a given ENS name
    /// @param ensName ENS name to lookup
    /// @return Address that controls ENS name
    function ensToAddr(string memory ensName) public view returns (address) {
        bytes32 ensNameHash = Namehash.namehash(ensName);
        return resolve(ensNameHash);
    }

    /// @notice Find a given text record for a given ENS name
    /// @param ensName ENS name to lookup
    /// @param key Text record key to lookup
    /// @return Text record if set
    function ensToText(string memory ensName, string memory key)
        public
        view
        returns (string memory)
    {
        bytes32 ensNameHash = Namehash.namehash(ensName);
        return text(ensNameHash, key);
    }

    /// @notice Find a given text record for a given namehash
    /// @param node Namehash for lookup
    /// @param key Text record key to lookup
    /// @return Text record if set
    function text(bytes32 node, string memory key)
        public
        view
        returns (string memory)
    {
        Resolver resolver = ens.resolver(node);
        return resolver.text(node, key);
    }

    /// @notice Get resolver from registry contract (for testing)
    /// @param node Namehash of ENS name whose resolver we want
    /// @return Resolver for given ENS name
    function getResolver(bytes32 node) public view returns (Resolver) {
        return ens.resolver(node);
    }

    /// @notice Find address for a given ENS namehash
    /// @param node Namehash of ENS name to lookup
    /// @return Address that controls ENS name
    function resolve(bytes32 node) public view returns (address) {
        Resolver resolver = ens.resolver(node);
        if (address(resolver) == address(0)) {
            return address(0);
        }
        return resolver.addr(node);
    }
}

/// @title ENS registry interface
abstract contract ENS {
    /// @notice Get resolver from registry contract
    /// @param node Namehash of ENS name whose resolver we want
    /// @return Resolver for given ENS name
    function resolver(bytes32 node) public view virtual returns (Resolver);
}

/// @title ENS resolver interface
abstract contract Resolver {
    /// @notice Find address for a given ENS namehash
    /// @param node Namehash of ENS name to lookup
    /// @return Address that controls ENS name
    function addr(bytes32 node) public view virtual returns (address);

    /// @notice Find a given text record for a given namehash
    /// @param node Namehash for lookup
    /// @param key Text record key to lookup
    /// @return Text record if set
    function text(bytes32 node, string memory key)
        public
        view
        virtual
        returns (string memory);
}

/// @title ENS reverse records interface
abstract contract ReverseRecords {
    /// @notice Get names for addresses
    /// @param addresses Addresses to lookup
    /// @return names Corresponding names for addresses
    function getNames(address[] calldata addresses)
        external
        view
        virtual
        returns (string[] memory names);
}

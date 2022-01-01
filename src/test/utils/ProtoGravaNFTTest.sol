// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

/// ============ External Imports ============

import "ds-test/test.sol";

/// ============ Internal Imports ============

import "../../ProtoGravaNFT.sol";
import "./ProtoGravaNFTUser.sol";

abstract contract ProtoGravaNFTTest is DSTest {
    /// ============ Storage ============

    /// @dev ProtoGravaNFT contract
    ProtoGravaNFT internal protogravanft;
    /// @dev User: Alice (in Merkle tree)
    ProtoGravaNFTUser internal alice;
    /// @dev User: Alice (NOT in merkle tree)
    ProtoGravaNFTUser internal bob;

    function setUp() public virtual {
        protogravanft = new ProtoGravaNFT(
            "ProtoGravaNFT",
            "PROTOGRAV",
            // Merkle root w/ Alice & Gravatar hash 60f9...3705 but no BOB
            0x203a4d8e6ceef6b0b9e14b36d43263fe81b2c4499fc17c6e04dbcf32a3728b19
        );
        alice = new ProtoGravaNFTUser(protogravanft); // 0x109F93893aF4C4b0afC7A9e97B59991260F98313
        bob = new ProtoGravaNFTUser(protogravanft); // 0x689856e2a6eb68fc33099eb2ccba0a5a4e8be52f
    }

    /// @notice Generates a Gravatar image URI
    /// @param gravatarHash for this specific token URI
    /// @param name for this specific token URI
    function formatTokenURI(string memory gravatarHash, string memory name)
        public
        view
        returns (string memory)
    {
        return protogravanft.formatTokenURI(gravatarHash, name);
    }
}

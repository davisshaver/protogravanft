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
    /// @dev User: Bob (NOT in merkle tree)
    ProtoGravaNFTUser internal bob;
    /// @dev User: Charlie (in merkle tree)
    ProtoGravaNFTUser internal charlie;

    function setUp() public virtual {
        protogravanft = new ProtoGravaNFT(
            "ProtoGravaNFT",
            "PROTOGRAV",
            // Merkle root w/ Alice & Charlie allowed, but no Bob
            0x9b8cafed119f35921d05fc33f23e26b005398f9ff6b905290277dd093f4ac830
        );
        alice = new ProtoGravaNFTUser(protogravanft); // 0x109F93893aF4C4b0afC7A9e97B59991260F98313
        bob = new ProtoGravaNFTUser(protogravanft); // 0x689856e2a6eb68fc33099eb2ccba0a5a4e8be52f
        charlie = new ProtoGravaNFTUser(protogravanft); // 0x2B0f159443599FBB6723CDB33d0DB94F96B95d0F
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

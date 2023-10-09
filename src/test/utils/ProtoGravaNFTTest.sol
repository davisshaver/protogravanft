// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

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
            0x84b89b6fc1e4c5386ace0530319d3b5609933b893ee8f48a1c1c43cd76428ffe
        );
        alice = new ProtoGravaNFTUser(protogravanft); // 0x2e234dae75c793f67a35089c9d99245e1c58470b
        bob = new ProtoGravaNFTUser(protogravanft); // 0xf62849f9a0b5bf2913b396098f7c7019b51a820a
        charlie = new ProtoGravaNFTUser(protogravanft); // 0x5991a2df15a8f6a256d3ec51e99254cd3fb576a9
    }
}

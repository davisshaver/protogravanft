// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

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
            0xf410dc13458d3fcdf2e6238d6849c17974685fa9b940848daf9f877b99b74c0f
        );
        alice = new ProtoGravaNFTUser(protogravanft); // 0x185a4dc360ce69bdccee33b3784b0282f7961aea
        bob = new ProtoGravaNFTUser(protogravanft); // 0xefc56627233b02ea95bae7e19f648d7dcd5bb132
        charlie = new ProtoGravaNFTUser(protogravanft); // 0xf5a2fe45f4f1308502b1c136b9ef8af136141382
    }
}

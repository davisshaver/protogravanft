// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/// ============ External Imports ============

import {Test} from "forge-std/Test.sol";

/// ============ Internal Imports ============

import {ProtoGravaNFT} from "../../ProtoGravaNFT.sol";
import {ProtoGravaNFTUser} from "./ProtoGravaNFTUser.sol";

abstract contract ProtoGravaNFTTest is Test {
    /// ============ Storage ============

    /// @dev ProtoGravaNFT contract
    ProtoGravaNFT internal protogravanft;
    /// @dev User: Alice
    ProtoGravaNFTUser internal alice;
    /// @dev User: Bob
    ProtoGravaNFTUser internal bob;
    /// @dev User: Charlie
    ProtoGravaNFTUser internal charlie;

    function setUp() public virtual {
        protogravanft = new ProtoGravaNFT("ProtoGravaNFT", "PROTOGRAV");
        alice = new ProtoGravaNFTUser(protogravanft); // 0x2e234dae75c793f67a35089c9d99245e1c58470b
        bob = new ProtoGravaNFTUser(protogravanft); // 0xf62849f9a0b5bf2913b396098f7c7019b51a820a
        charlie = new ProtoGravaNFTUser(protogravanft); // 0x5991a2df15a8f6a256d3ec51e99254cd3fb576a9
    }
}

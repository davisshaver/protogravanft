// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/// ============ External Imports ============

import {Test} from "forge-std/Test.sol";

/// ============ Internal Imports ============

import {ProtoGravaNFT} from "../../ProtoGravaNFT.sol";

/// @title ProtoGravaNFTUser
/// @notice Mock ProtoGravaNFT user
contract ProtoGravaNFTUser is Test {
    /// ============ Immutable storage ============

    /// @dev ProtoGravaNFT contract
    ProtoGravaNFT internal immutable PROTOGRAVANFT;

    /// ============ Constructor ============

    /// @notice Creates a new ProtoGravaNFTUser
    /// @param _protogravanft ProtoGravaNFT contract
    constructor(ProtoGravaNFT _protogravanft) {
        PROTOGRAVANFT = _protogravanft;
    }

    /// ============ Helper functions ============

    /// @notice Returns user's token balance
    function getAddress() public view returns (address) {
        return address(this);
    }

    /// @notice Returns user's token balance
    function tokenBalance() public view returns (uint256) {
        return PROTOGRAVANFT.balanceOf(getAddress());
    }

    /// ============ Inherited functionality ============

    /// @notice Mint a token
    function mint() public {
        return PROTOGRAVANFT.mint();
    }

    /// @notice Transfer a token
    /// @param to address receiving transfer
    /// @param id of token being transferred
    function transferFrom(address to, uint256 id) public {
        return PROTOGRAVANFT.transferFrom(getAddress(), to, id);
    }

    function ownerSetDescription(string calldata _description) public {
        return PROTOGRAVANFT.ownerSetDescription(_description);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) public {
        return PROTOGRAVANFT.burn(id);
    }
}

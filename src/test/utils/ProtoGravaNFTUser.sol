// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

/// ============ Internal Imports ============

import "../../ProtoGravaNFT.sol";

/// @title ProtoGravaNFTUser
/// @notice Mock ProtoGravaNFT user
contract ProtoGravaNFTUser {
    /// ============ Immutable storage ============

    /// @dev ProtoGravaNFT contract
    ProtoGravaNFT internal immutable protogravanft;

    /// ============ Constructor ============

    /// @notice Creates a new ProtoGravaNFTUser
    /// @param _protogravanft ProtoGravaNFT contract
    constructor(ProtoGravaNFT _protogravanft) {
        protogravanft = _protogravanft;
    }

    /// ============ Helper functions ============

    /// @notice Returns user's token balance
    function getAddress() public view returns (address) {
        return address(this);
    }

    /// @notice Returns user's token balance
    function tokenBalance() public view returns (uint256) {
        return protogravanft.balanceOf(getAddress());
    }

    /// ============ Inherited functionality ============

    /// @notice Mint a token
    /// @param gravatarHash of token being minted
    /// @param proof of Gravatar hash ownership
    function mint(
        string calldata gravatarHash,
        bytes32[] calldata proof,
        uint128 transferLimit
    ) public {
        return protogravanft.mint(gravatarHash, proof, transferLimit);
    }

    /// @notice Transfer a token
    /// @param to address receiving transfer
    /// @param id of token being transferred
    function transferFrom(address to, uint256 id) public {
        return protogravanft.transferFrom(getAddress(), to, id);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) public {
        return protogravanft.burn(id);
    }
}

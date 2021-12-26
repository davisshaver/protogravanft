// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";

import "../../ProtoGravaNFT.sol";

contract User {
    ProtoGravaNFT internal protogravanft;

    constructor(address _protogravanft) {
        protogravanft = ProtoGravaNFT(_protogravanft);
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function ownerMint(string memory gravatarHash) public returns (uint256) {
        return
            protogravanft.ownerMint(gravatarHash, gravatarHash, address(this));
    }

    function publicMint(string memory gravatarHash, bytes32[] memory _proof)
        public
        returns (uint256)
    {
        return protogravanft.publicMint(gravatarHash, gravatarHash, _proof);
    }

    function formatTokenURI(
        string memory gravatarHash,
        string memory gravatarName
    ) public view returns (string memory) {
        return
            protogravanft.formatTokenURI(
                gravatarHash,
                gravatarName,
                "Globally Recognized Avatars on the Ethereum Blockchain",
                "robohash"
            );
    }
}

abstract contract ProtoGravaNFTTest is DSTest {
    ProtoGravaNFT internal protogravanft;

    User internal alice;
    User internal bob;

    function setUp() public virtual {
        protogravanft = new ProtoGravaNFT(
            "ProtoGravaNFT",
            "PROTOGRAV",
            0x31ec1fc12927b46ccb39c33438bcb5206998698ffe2c5356f6b3c16be0b989fd
        );
        alice = new User(address(protogravanft));
        bob = new User(address(protogravanft));
        protogravanft.transferOwnership(address(alice));
    }
}

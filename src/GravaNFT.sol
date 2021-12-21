// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Libraries.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "base64-sol/base64.sol";

abstract contract ReverseRecords {
    function getNames(address[] calldata addresses)
        external
        view
        virtual
        returns (string[] memory r);
}

library Errors {
    // we don't strictly _need_ you to have ENS reverse resolution setup for these ERC-721 tokens, aka NFTs,
    // but ENS is a textbook example of what highly-functioning web3 efforts look like by delivering massive value as
    // a protocol level while also iterating on bedrock web principles like public benefit, interopability,
    // composability, and democratic governance. https://docs.ens.domains/v/governance/ens-dao-constitution
    string internal constant ErrorENSResolution =
        "gm, plz setup an ENS reverse record to continue: https://twitter.com/ensdomains/status/1392152087249698822";
    // wish I could name a nonprofit here, but haven't talked to anyone yet. this is my commitment to go off-chain
    // to verify a nonprofit recipient and make sure that we can document transfer of funds to the organization.
    // that all said, check out getNonprofitRecipient() for the answer, once we have confirmed a recipient.
    string internal constant ErrorETHAmount =
        "howdy, thank u in advance for including .013 eth (~$50 USD at present) for a TBD nonprofit";
    // right now, minting is only available to the contract author and select other gravatar users considered public figures.
    // if you would like to be included, send a message to the email address derived by the following WP function:
    // 
    string internal constant ErrorUnauthorizedHash =
        "th address is not authorized for provided hash";
}

contract GravaNFT is ERC721URIStorage, Ownable {
    constructor() ERC721("Gravatars", "GRAV") {}

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // @TODO Update this for mainnet.
    address public ensReverseResolution =
        0x72c33B247e62d0f1927E8d325d0358b8f9971C68;

    // @TODO Use something other than random StackOverflow string function.
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    // @TODO Same as above.
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    // @TODO Write function docs and test this.
    function addrToENS(address addr) public view returns (string[] memory) {
        ReverseRecords ens = ReverseRecords(ensReverseResolution);
        address[] memory t = new address[](1);
        t[0] = addr;
        return ens.getNames(t);
    }

    // @TODO Write function docs and test this.
    // @TODO Add support for default 'd' option: 404, mp, identicon, monsterid, wavatar, retro, robohash, blank
    function formatTokenURI(
        string memory gravatarHash,
        string memory gravatarName
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            bytes(
                                abi.encodePacked(
                                    '{"name":"',
                                    gravatarName,
                                    '", "description": "Globally Recognized Avatars", "image": "//secure.gravatar.com/avatar/',
                                    gravatarHash,
                                    '?s=2048&d=retro"}'
                                )
                            )
                        )
                    )
                )
            );
    }

    // @TODO Write function docs and test this.
    // @TODO Add support for emails to hash (trim, lowercase, md5).
    // @TODO Add support for overriding name.
    // @TODO Add owner ability to change description.
    function mintFreeGravatar(
        address gravatarMinter,
        string memory gravatarHash
    ) public onlyOwner returns (uint256) {
        string[] memory ensNames = addrToENS(gravatarMinter);
        string memory gravatarName = keccak256(abi.encodePacked(ensNames[0])) !=
            keccak256(abi.encodePacked(""))
            ? ensNames[0]
            : toAsciiString(gravatarMinter);
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(gravatarMinter, newItemId);
        _setTokenURI(newItemId, formatTokenURI(gravatarHash, gravatarName));
        return newItemId;
    }
}

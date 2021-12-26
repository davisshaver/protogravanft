// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Open Zeppelin modules and other libraries.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol"; // Sorry @transmissions11
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "base64-sol/base64.sol";

library Defaults {
    string internal constant DefaultDescription =
        "Globally Recognized Avatars on the Ethereum Blockchain";
    string internal constant DefaultForDefaultImage = "robohash";
}

library Errors {
    string internal constant ErrorUnauthorizedHash = "address/hash invalid";
    string internal constant ErrorHashAlreadyUsed = "hash already used";
}

contract ProtoGravaNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /// @dev Mapping of hashes to addresses for usage tracking.
    /// @dev TODO: Try to map hashes to unique integers for use as token ID.
    mapping(string => address) private gravUses;

    /// @dev Merkle root to verify an address' claim for a specific hash.
    bytes32 public merkleRoot;

    /// @dev Default fallback image for tokens minted in future blocks.
    string public defaultFormat;

    /// @dev Description for tokens minted in future blocks.
    string public description;

    /// @dev Buckle up!
    constructor(
        string memory name,
        string memory symbol,
        bytes32 _merkleRoot
    ) ERC721(name, symbol) {
        defaultFormat = Defaults.DefaultForDefaultImage;
        description = Defaults.DefaultDescription;
        merkleRoot = _merkleRoot;
    }

    /// @dev Helper function to format a base64 URI for token.
    function formatTokenURI(
        string calldata gravHash,
        string calldata gravName,
        string memory gravDescription,
        string memory gravDefault
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            bytes(
                                abi.encodePacked(
                                    "{'name':'",
                                    gravName,
                                    "', 'description': '",
                                    gravDescription,
                                    "', 'image': '//secure.gravatar.com/avatar/",
                                    gravHash,
                                    "?s=2048&d=",
                                    gravDefault,
                                    "'}"
                                )
                            )
                        )
                    )
                )
            );
    }

    /// @dev Internal function to mint token w/ name, hash, and recipient.
    function mint(
        string calldata gravName,
        string calldata gravHash,
        address gravRecipient
    ) private returns (uint256) {
        require(gravUses[gravHash] == address(0), Errors.ErrorHashAlreadyUsed);
        string memory gravTokenURI = formatTokenURI(
            gravName,
            gravHash,
            description,
            defaultFormat
        );
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(gravRecipient, newItemId);
        _setTokenURI(newItemId, gravTokenURI);
        gravUses[gravHash] = gravRecipient;
        return newItemId;
    }

    /// @dev Generates leaf for adress and hash pair.
    function _leaf(address account, string calldata gravHash)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(gravHash, account));
    }

    /// @dev Verifies leaf and proof against Merkle tree root.
    function _verify(bytes32 leaf, bytes32[] calldata proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    /// @dev Allow public to mint tokens for hashes mapped to their wallet.
    function publicMint(
        string calldata gravName,
        string calldata gravHash,
        bytes32[] calldata _proof
    ) public returns (uint256) {
        require(
            _verify(_leaf(msg.sender, gravHash), _proof),
            Errors.ErrorUnauthorizedHash
        );
        return mint(gravName, gravHash, msg.sender);
    }

    /// @dev Allow owners to mint any address a token for any unused hash.
    function ownerMint(
        string calldata gravName,
        string calldata gravHash,
        address gravRecipient
    ) public onlyOwner returns (uint256) {
        return
            mint(
                gravName,
                gravHash,
                gravRecipient == address(0) ? msg.sender : gravRecipient
            );
    }

    /// @dev Update default Gravatar image format for future tokens.
    function ownerSetDefaultFormat(string calldata _defaultFormat)
        public
        onlyOwner
    {
        defaultFormat = _defaultFormat;
    }

    /// @dev Update the description for future tokens.
    function ownerSetDescription(string calldata _description) public onlyOwner {
        description = _description;
    }

    /// @dev Update the Merkle root for future tokens.
    function ownerSetMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function getDescription() public view returns (string memory) {
        return description;
    }

    function getDefaultImageFormat() public view returns (string memory) {
        return defaultFormat;
    }
}

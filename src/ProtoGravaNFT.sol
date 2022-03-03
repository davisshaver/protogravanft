// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

/// ============ External Imports ============

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "solmate/tokens/ERC721.sol";

/// ============ Internal Imports ============

import "./LilENS.sol";
import "./LilOwnable.sol";

/// ============ Defaults ============

library Defaults {
    string internal constant DefaultDescription =
        "Globally Recognized Avatars on the Ethereum Blockchain";
    string internal constant DefaultForDefaultImage = "robohash";
}

/// @title ProtoGravaNFT
/// @notice Gravatar-powered ERC721 claimable by members of a Merkle tree
/// @author Davis Shaver <davisshaver@gmail.com>
contract ProtoGravaNFT is ERC721, LilENS, LilOwnable {
    /// ============ Immutable Storage ============

    /// @notice Max total supply of token
    uint256 public constant MAX_TOTAL_SUPPLY = type(uint256).max - 1;

    /// ============ Mutable Storage ============

    /// @notice Current total supply of token
    uint256 public totalSupply;

    /// @notice Mapping of ids to hashes
    mapping(uint256 => string) private gravIDsToHashes;

    /// @notice Mapping of ids to names
    mapping(uint256 => string) private gravIDsToNames;

    /// @notice Mapping of ids to number of transfers
    mapping(uint256 => uint256) private gravIDsToTransfers;

    /// @notice Mapping of ids to transfer limits
    mapping(uint256 => uint256) private gravIDsToTransferLimits;

    /// @notice Merkle root
    bytes32 public merkleRoot;

    /// @notice Default fallback image
    string public defaultFormat;

    /// @notice Description
    string public description;

    /// ============ Events ============

    /// @notice Emitted after a successful mint
    /// @param to which address
    /// @param hash that was claimed
    /// @param name that was used
    event Mint(address indexed to, string hash, string name);

    /// @notice Emitted after Merkle root is changed
    /// @param newMerkleRoot for validating claims
    event MerkleRootChanged(bytes32 newMerkleRoot);

    /// @notice Emitted after description is changed
    /// @param newDescription for all tokens
    event DescriptionChanged(string newDescription);

    /// @notice Emitted after default format is changed
    /// @param newDefaultFormat for all tokens
    event DefaultFormatChanged(string newDefaultFormat);

    /// ============ Errors ============

    /// @notice Thrown if a non-existent token is queried
    error DoesNotExist();

    /// @notice Thrown if unauthorized user tries to burn token
    error NotAuthorized();

    /// @notice Thrown if total supply is exceeded
    error NoTokensLeft();

    /// @notice Thrown if burn attempted on token not owned by address
    error NotAllowedToBurn();

    /// @notice Thrown if address/hash are not part of Merkle tree
    error NotInMerkle();

    /// @notice Thrown if transfer limit reached & prevents transfer
    error TransferLimitReached();

    /// ============ Constructor ============

    /// @notice Creates a new ProtoGravaNFT contract
    /// @param _name of token
    /// @param _symbol of token
    /// @param _merkleRoot of claimees
    constructor(
        string memory _name,
        string memory _symbol,
        bytes32 _merkleRoot
    ) ERC721(_name, _symbol) {
        defaultFormat = Defaults.DefaultForDefaultImage;
        description = Defaults.DefaultDescription;
        merkleRoot = _merkleRoot;
    }

    /* solhint-disable quotes */
    /// @notice Generates a Gravatar image URI for token
    /// @param gravatarHash for this specific token
    /// @param name for this specific token
    /// @return Token URI
    function formatTokenURI(string memory gravatarHash, string memory name)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            bytes(
                                abi.encodePacked(
                                    '{"name": "',
                                    name,
                                    '", "description": "',
                                    description,
                                    '", "image": "https://secure.gravatar.com/avatar/',
                                    gravatarHash,
                                    "?s=2048&d=",
                                    defaultFormat,
                                    '", "background_color": "4678eb", ',
                                    '"external_url": "https://www.gravatar.com/',
                                    gravatarHash,
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    /* solhint-enable quotes */

    /// @notice Mint a token
    /// @param name of token being minted
    /// @param gravatarHash of token being minted
    /// @param proof of Gravatar hash ownership
    /// @param transferLimit of token
    function mint(
        string calldata name,
        string calldata gravatarHash,
        bytes32[] calldata proof,
        uint256 transferLimit
    ) external {
        if (totalSupply + 1 >= MAX_TOTAL_SUPPLY) revert NoTokensLeft();

        bytes32 leaf = keccak256(abi.encodePacked(gravatarHash, msg.sender));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isValidLeaf) revert NotInMerkle();

        uint256 newItemId = totalSupply++;
        gravIDsToHashes[newItemId] = gravatarHash;
        gravIDsToNames[newItemId] = name;
        gravIDsToTransferLimits[newItemId] = transferLimit;

        _mint(msg.sender, newItemId);

        emit Mint(msg.sender, gravatarHash, name);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) external {
        if (msg.sender != ownerOf[id]) revert NotAllowedToBurn();
        delete gravIDsToHashes[id];
        delete gravIDsToNames[id];
        delete gravIDsToTransferLimits[id];
        _burn(id);
    }

    /// @notice Transfer a token
    /// @param from address making transfer
    /// @param to address receiving transfer
    /// @param id of token being transferred
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        if (gravIDsToTransfers[id] + 1 > gravIDsToTransferLimits[id])
            revert TransferLimitReached();
        super.transferFrom(from, to, id);
        gravIDsToTransfers[id] = gravIDsToTransfers[id] + 1;
    }

    /// @notice Gets URI for a specific token
    /// @param id of token being queried
    /// @return Token URI
    function tokenURI(uint256 id) public view override returns (string memory) {
        if (ownerOf[id] == address(0)) revert DoesNotExist();

        return formatTokenURI(gravIDsToHashes[id], gravIDsToNames[id]);
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param _defaultFormat for Gravatar image API
    function ownerSetDefaultFormat(string calldata _defaultFormat) public {
        if (msg.sender != _owner) revert NotOwner();
        defaultFormat = _defaultFormat;

        emit DefaultFormatChanged(defaultFormat);
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param _description for tokens
    function ownerSetDescription(string calldata _description) public {
        if (msg.sender != _owner) revert NotOwner();
        description = _description;

        emit DescriptionChanged(description);
    }

    /// @notice Set a new Merkle root
    /// @param _merkleRoot for validating claims
    function ownerSetMerkleRoot(bytes32 _merkleRoot) public {
        if (msg.sender != _owner) revert NotOwner();
        merkleRoot = _merkleRoot;

        emit MerkleRootChanged(merkleRoot);
    }

    /// @notice Get the description
    /// @return Description
    function getDescription() public view returns (string memory) {
        return description;
    }

    /// @notice Get the default image format
    /// @return Default image format
    function getDefaultImageFormat() public view returns (string memory) {
        return defaultFormat;
    }

    /// @notice Declare supported interfaces
    /// @param interfaceId for support check
    /// @return Boolean for interface support
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(LilOwnable, ERC721)
        returns (bool)
    {
        return
            interfaceId == 0x7f5828d0 || // ERC165 Interface ID for ERC173
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC165
            interfaceId == 0x01ffc9a7; // ERC165 Interface ID for ERC721Metadata
    }
}

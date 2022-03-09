// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

/// ============ External Imports ============

import "base64-sol/base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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
    event Mint(address indexed to, string hash);

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

    /// @notice Get name of a token
    /// @param id for token being generated
    /// @return tokenName for ID
    /// @return hasEnsName for ID
    function getTokenName(uint256 id)
        public
        view
        returns (string memory tokenName, bool hasEnsName)
    {
        string memory ensName = addrToENS(ownerOf[id])[0];
        hasEnsName =
            keccak256(abi.encodePacked(ensName)) !=
            keccak256(abi.encodePacked(""));
        tokenName = hasEnsName
            ? ensName
            : Strings.toHexString(uint256(uint160(ownerOf[id])), 20);
        return (tokenName, hasEnsName);
    }

    /* solhint-disable quotes */
    /// @notice Get specific attribute for an ENS name
    /// @param ensName for owner of token being generated
    /// @param attributeKey for ENS lookup
    /// @param attributeLabel for token attributes
    /// @return attribute value for token
    function getAttribute(
        string memory ensName,
        string memory attributeKey,
        string memory attributeLabel,
        bool includeTrailingComma
    ) public view returns (string memory attribute) {
        string memory attributeValue = ensToText(ensName, attributeKey);
        string memory maybeTrailingComma = includeTrailingComma ? ", " : "";
        attribute = string(
            abi.encodePacked(
                '{ "trait_type": "',
                attributeLabel,
                '", "value": "',
                attributeValue,
                '" }',
                maybeTrailingComma
            )
        );
        return attribute;
    }

    /* solhint-enable quotes */

    /* solhint-disable quotes */
    /// @notice Get attributes of a token
    /// @param ensName for owner of token being generated
    /// @return tokenAttributes for token
    function getTokenAttributes(string memory ensName)
        public
        view
        returns (string memory tokenAttributes)
    {
        string memory tokenAttributesStart = '"attributes": [';
        string memory tokenAttributesEnd = "]";
        string memory locationAttribute = getAttribute(
            ensName,
            "location",
            "Location",
            true
        );
        string memory emailAttribute = getAttribute(
            ensName,
            "email",
            "Email",
            true
        );
        string memory urlAttribute = getAttribute(ensName, "url", "URL", true);
        string memory githubAttribute = getAttribute(
            ensName,
            "com.github",
            "Github",
            true
        );
        string memory twitterAttribute = getAttribute(
            ensName,
            "com.twitter",
            "Twitter",
            true
        );
        string memory discordAttribute = getAttribute(
            ensName,
            "com.discord",
            "Discord",
            true
        );
        string memory telegramAttribute = getAttribute(
            ensName,
            "org.telegram",
            "Telegram",
            false
        );
        tokenAttributes = string(
            abi.encodePacked(
                tokenAttributesStart,
                locationAttribute,
                emailAttribute,
                urlAttribute,
                twitterAttribute,
                githubAttribute,
                discordAttribute,
                telegramAttribute,
                tokenAttributesEnd
            )
        );
        return tokenAttributes;
    }

    /* solhint-enable quotes */

    /* solhint-disable quotes */
    /// @notice Generates a Gravatar image URI for token
    /// @param id for this specific token
    /// @return generatedTokenURI for this specific token
    function formatTokenURI(uint256 id)
        public
        view
        returns (string memory generatedTokenURI)
    {
        (string memory tokenName, bool hasEnsName) = getTokenName(id);
        string memory tokenAttributes = hasEnsName
            ? getTokenAttributes(tokenName)
            : '"attributes": []';
        generatedTokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                tokenName,
                                '", "description": "',
                                description,
                                '", "image": "https://secure.gravatar.com/avatar/',
                                gravIDsToHashes[id],
                                "?s=2048&d=",
                                defaultFormat,
                                '", "background_color": "4678eb", ',
                                '"external_url": "https://www.gravatar.com/',
                                gravIDsToHashes[id],
                                '", ',
                                tokenAttributes,
                                "}"
                            )
                        )
                    )
                )
            )
        );
        return generatedTokenURI;
    }

    /* solhint-enable quotes */

    /// @notice Mint a token
    /// @param gravatarHash of token being minted
    /// @param proof of Gravatar hash ownership
    /// @param transferLimit of token
    function mint(
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
        gravIDsToTransferLimits[newItemId] = transferLimit;

        _mint(msg.sender, newItemId);

        emit Mint(msg.sender, gravatarHash);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) external {
        if (msg.sender != ownerOf[id]) revert NotAllowedToBurn();
        delete gravIDsToHashes[id];
        delete gravIDsToTransfers[id];
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
    /// @return formattedTokenURI of token being queried
    function tokenURI(uint256 id)
        public
        view
        override
        returns (string memory formattedTokenURI)
    {
        if (ownerOf[id] == address(0)) revert DoesNotExist();

        formattedTokenURI = formatTokenURI(id);
        return formattedTokenURI;
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
    /// @return description
    function getDescription() public view returns (string memory) {
        return description;
    }

    /// @notice Get the default image format
    /// @return defaultFormat Default image format
    function getDefaultImageFormat() public view returns (string memory) {
        return defaultFormat;
    }

    /// @notice Declare supported interfaces
    /// @param interfaceId for support check
    /// @return interfaceSupported
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override(LilOwnable, ERC721)
        returns (bool interfaceSupported)
    {
        interfaceSupported =
            interfaceId == 0x7f5828d0 || // ERC165 Interface ID for ERC173
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC165
            interfaceId == 0x01ffc9a7; // ERC165 Interface ID for ERC721Metadata
        return interfaceSupported;
    }
}

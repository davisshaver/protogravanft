// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

/*//////////////////////////////////////////////////////////////
                        EXTERNAL IMPORTS
//////////////////////////////////////////////////////////////*/

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "solmate/tokens/ERC721.sol";

/*//////////////////////////////////////////////////////////////
                        INTERNAL IMPORTS
//////////////////////////////////////////////////////////////*/

import "./LilBase64.sol";
import "./LilENS.sol";
import "./LilOwnable.sol";

/*//////////////////////////////////////////////////////////////
                            DEFAULTS
//////////////////////////////////////////////////////////////*/

library Defaults {
    string internal constant DefaultDescription =
        "Globally Recognized Avatars on the Ethereum Blockchain";
    string internal constant DefaultForDefaultImage = "robohash";
}

/*//////////////////////////////////////////////////////////////
                                EVENTS
//////////////////////////////////////////////////////////////*/

library Events {
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
}

/// @title ProtoGravaNFT
/// @notice Gravatar-powered ERC721 claimable by members of a Merkle tree
/// @author Davis Shaver <davisshaver@gmail.com>
contract ProtoGravaNFT is ERC721, LilENS, LilOwnable {
    /*//////////////////////////////////////////////////////////////
                            IMMUTABLE STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Max total number of minted tokens
    uint256 public constant MAX_TOTAL_MINTED = type(uint256).max - 1;

    /*//////////////////////////////////////////////////////////////
                             MUTABLE STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Current total number of minted tokens
    uint256 public totalMinted;

    /// @notice Current total number of burned tokens
    uint256 public totalBurned;

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

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Throws if a non-owner of contract calls function
    modifier onlyContractOwner() {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }

    /// @notice Throws if called with an id that does not exist
    /// @param id for token being called
    modifier tokenExists(uint256 id) {
        if (_ownerOf[id] == address(0)) revert DoesNotExist();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

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

    /// @notice Get total non-burned supply of token
    /// @return result for totalSupply check
    function totalSupply() public view returns (uint256 result) {
        unchecked {
            result = totalMinted - totalBurned;
        }
    }

    /// @notice Get name of a token
    /// @dev Extra check to ensure ENS forward & reverse resolution match
    /// @param id for token being generated
    /// @return tokenName for ID
    /// @return hasEnsName for ID
    function getTokenName(uint256 id)
        public
        view
        tokenExists(id)
        returns (string memory tokenName, bool hasEnsName)
    {
        string memory ensName = addrToENS(_ownerOf[id])[0];
        hasEnsName = bytes(ensName).length > 0;
        if (hasEnsName) {
            address ensAddress = ensToAddr(ensName);
            if (ensAddress != _ownerOf[id]) {
                hasEnsName = false;
            }
        }
        tokenName = hasEnsName
            ? ensName
            : Strings.toHexString(uint256(uint160(_ownerOf[id])), 20);
        return (tokenName, hasEnsName);
    }

    /* solhint-disable quotes */
    /// @notice Get specific attribute for an ENS name
    /// @param ensName for owner of token being generated
    /// @param attributeKey for ENS lookup
    /// @param attributeLabel for token attributes
    /// @param includeTrailingComma after token data
    /// @return attribute value for token
    function getAttribute(
        string memory ensName,
        string memory attributeKey,
        string memory attributeLabel,
        bool includeTrailingComma
    ) private view returns (string memory attribute) {
        string memory attributeValue = ensToText(ensName, attributeKey);
        string memory maybeTrailingComma = includeTrailingComma ? ", " : "";
        attribute = string(
            string.concat(
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
        private
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
            string.concat(
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
    /// @notice Generates base64 payload for token
    /// @param id for this specific token
    /// @return generatedTokenURIBase64 for this specific token
    function generateTokenURIBase64(uint256 id)
        public
        view
        tokenExists(id)
        returns (string memory generatedTokenURIBase64)
    {
        (string memory tokenName, bool hasEnsName) = getTokenName(id);
        string memory tokenAttributes = hasEnsName
            ? getTokenAttributes(tokenName)
            : '"attributes": []';
        generatedTokenURIBase64 = LilBase64.encode(
            bytes(
                string.concat(
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
        );
    }

    /* solhint-enable quotes */

    /// @notice Mint a token
    /// @dev Note: Transfer limit not part of proof, set by minter
    /// @param gravatarHash of token being minted
    /// @param proof of Gravatar hash ownership
    /// @param transferLimit of token
    function mint(
        string calldata gravatarHash,
        bytes32[] calldata proof,
        uint128 transferLimit
    ) external {
        if (totalMinted + 1 >= MAX_TOTAL_MINTED) revert NoTokensLeft();

        bytes32 leaf = keccak256(abi.encodePacked(gravatarHash, msg.sender));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        if (!isValidLeaf) revert NotInMerkle();

        uint256 newItemId = ++totalMinted;
        gravIDsToHashes[newItemId] = gravatarHash;
        gravIDsToTransferLimits[newItemId] = transferLimit;

        _mint(msg.sender, newItemId);

        emit Events.Mint(msg.sender, gravatarHash);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) external {
        if (msg.sender != _ownerOf[id]) revert NotAllowedToBurn();
        _burn(id);
        totalBurned++;
        delete gravIDsToHashes[id];
        delete gravIDsToTransfers[id];
        delete gravIDsToTransferLimits[id];
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
        tokenExists(id)
        returns (string memory formattedTokenURI)
    {
        formattedTokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                generateTokenURIBase64(id)
            )
        );
        return formattedTokenURI;
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param _defaultFormat for Gravatar image API
    function ownerSetDefaultFormat(string calldata _defaultFormat)
        public
        onlyContractOwner
    {
        defaultFormat = _defaultFormat;

        emit Events.DefaultFormatChanged(defaultFormat);
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param _description for tokens
    function ownerSetDescription(string calldata _description)
        public
        onlyContractOwner
    {
        description = _description;

        emit Events.DescriptionChanged(description);
    }

    /// @notice Set a new Merkle root
    /// @dev This function may be replacable with an implementation of EIP-3668
    /// @param _merkleRoot for validating claims
    function ownerSetMerkleRoot(bytes32 _merkleRoot) public onlyContractOwner {
        merkleRoot = _merkleRoot;

        emit Events.MerkleRootChanged(merkleRoot);
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

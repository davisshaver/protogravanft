// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/*//////////////////////////////////////////////////////////////
                        EXTERNAL IMPORTS
//////////////////////////////////////////////////////////////*/

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

/*//////////////////////////////////////////////////////////////
                        INTERNAL IMPORTS
//////////////////////////////////////////////////////////////*/

import {LilBase64} from "./LilBase64.sol";
import {LilENS} from "./LilENS.sol";
import {LilOwnable} from "./LilOwnable.sol";
import {LilHash} from "./LilHash.sol";

/*//////////////////////////////////////////////////////////////
                            DEFAULTS
//////////////////////////////////////////////////////////////*/

library Defaults {
    string internal constant DEFAULT_DESCRIPTION =
        "Globally Recognized Avatars on the Ethereum Blockchain";
    string internal constant DEFAULT_FOR_DEFAULT_IMAGE = "robohash";
}

/*//////////////////////////////////////////////////////////////
                                EVENTS
//////////////////////////////////////////////////////////////*/

library Events {
    /// @notice Emitted after a successful mint
    /// @param to which address
    event Mint(address indexed to);

    /// @notice Emitted after description is changed
    /// @param newDescription for all tokens
    event DescriptionChanged(string newDescription);

    /// @notice Emitted after default format is changed
    /// @param newDefaultFormat for all tokens
    event DefaultFormatChanged(string newDefaultFormat);

    /// @notice Emitted after public minting is toggled
    /// @param isPublicMintEnabled for all tokens
    event PublicMintToggled(bool isPublicMintEnabled);
}

/// @title ProtoGravaNFT
/// @notice Gravatar-powered ERC721 claimable by anyone
/// @author Davis Shaver <davisshaver@gmail.com>
contract ProtoGravaNFT is ERC721, LilENS, LilOwnable, LilHash {
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

    /// @notice Default fallback image
    string public defaultFormat;

    /// @notice Description
    string public description;

    bool public isPublicMintEnabled;

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

    /// @notice Throws if called when public minting is disabled
    modifier onlyWhenPublicMintEnabled() {
        if (!isPublicMintEnabled && msg.sender != _owner)
            revert PublicMintDisabled();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown if a non-existent token is queried
    error DoesNotExist();

    /// @notice Thrown if the address does not have an ENS name
    error NoENSName();

    /// @notice Thrown if the ENS profile does not have an email address
    error NoENSEmailTextRecord();

    /// @notice Thrown if total supply is exceeded
    error NoTokensLeft();

    /// @notice Thrown if burn attempted on token not owned by address
    error NotAllowedToBurn();

    /// @notice Thrown if user attempts to mint more than one token
    error OnePerUser();

    /// @notice Thrown if public minting is disabled
    error PublicMintDisabled();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates a new ProtoGravaNFT contract
    /// @param _name of token
    /// @param _symbol of token
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        defaultFormat = Defaults.DEFAULT_FOR_DEFAULT_IMAGE;
        description = Defaults.DEFAULT_DESCRIPTION;
        isPublicMintEnabled = true;
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
    function getTokenName(
        uint256 id
    )
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
    function getTokenAttributes(
        string memory ensName
    ) private view returns (string memory tokenAttributes) {
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
    function generateTokenURIBase64(
        uint256 id
    )
        public
        view
        tokenExists(id)
        returns (string memory generatedTokenURIBase64)
    {
        (string memory tokenName, bool hasEnsName) = getTokenName(id);
        if (!hasEnsName) {
            revert NoENSName();
        }
        string memory emailAddress = ensToText(tokenName, "email");
        if (bytes(emailAddress).length == 0) {
            revert NoENSEmailTextRecord();
        }
        string memory hashedEmail = hashNormalizedString(emailAddress);
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
                    hashedEmail,
                    "?s=2048&d=",
                    defaultFormat,
                    '", "background_color": "4678eb", ',
                    '"external_url": "https://www.gravatar.com/',
                    hashedEmail,
                    '", ',
                    tokenAttributes,
                    "}"
                )
            )
        );
    }

    /* solhint-enable quotes */

    /// @notice Airdrop a token
    function airdrop(address to) external onlyContractOwner {
        mintTo(to);
    }

    /// @notice Mint a token
    function mint() external onlyWhenPublicMintEnabled {
        mintTo(msg.sender);
    }

    /// @notice Mint a token to an address
    function mintTo(address to) internal {
        if (totalMinted + 1 >= MAX_TOTAL_MINTED) revert NoTokensLeft();

        if (balanceOf(to) > 0) revert OnePerUser();

        uint256 newItemId = ++totalMinted;

        _mint(to, newItemId);

        emit Events.Mint(to);
    }

    /// @notice Burn a token
    /// @param id of token being burned
    function burn(uint256 id) external {
        if (msg.sender != _ownerOf[id]) revert NotAllowedToBurn();
        _burn(id);
        totalBurned++;
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
        if (balanceOf(to) > 0) revert OnePerUser();
        super.transferFrom(from, to, id);
    }

    /// @notice Gets URI for a specific token
    /// @param id of token being queried
    /// @return formattedTokenURI of token being queried
    function tokenURI(
        uint256 id
    )
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

    /// @notice Toggle public minting
    function ownerTogglePublicMint() public onlyContractOwner {
        isPublicMintEnabled = !isPublicMintEnabled;
        emit Events.PublicMintToggled(isPublicMintEnabled);
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param newDefaultFormat for Gravatar image API
    function ownerSetDefaultFormat(
        string calldata newDefaultFormat
    ) public onlyContractOwner {
        defaultFormat = newDefaultFormat;

        emit Events.DefaultFormatChanged(defaultFormat);
    }

    /// @notice Update default Gravatar image format for future tokens
    /// @param newDescription for tokens
    function ownerSetDescription(
        string calldata newDescription
    ) public onlyContractOwner {
        description = newDescription;

        emit Events.DescriptionChanged(description);
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
    function supportsInterface(
        bytes4 interfaceId
    )
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

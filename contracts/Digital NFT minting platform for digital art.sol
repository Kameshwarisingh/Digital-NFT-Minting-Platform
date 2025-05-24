// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title DigitalArtNFT
 * @dev A simple NFT minting platform for digital art
 */
contract DigitalArtNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public royaltyBps;
    
    uint256 public defaultRoyaltyBps = 250; // 2.5%
    uint256 public constant MAX_ROYALTY_BPS = 1000; // 10%
    uint256 public platformFeeBps = 100; // 1%
    
    address public platformFeeRecipient;

    event NFTMinted(uint256 indexed tokenId, address indexed creator, string tokenURI);
    event RoyaltySet(uint256 indexed tokenId, uint256 royaltyBps);
    event PlatformFeeUpdated(uint256 platformFeeBps);
    event PlatformFeeRecipientUpdated(address platformFeeRecipient);

    /**
     * @dev Constructor initializes the NFT collection with default values
     */
    constructor() ERC721("DigitalArtNFT", "DANFT") Ownable(msg.sender) {
        platformFeeRecipient = msg.sender; // default to deployer
    }

    /**
     * @dev Mint a new NFT
     * @param tokenURI URI pointing to the metadata
     * @param royaltyBasisPoints Royalty percentage in basis points (optional, 0 for default)
     * @return The new token ID
     */
    function mintNFT(string memory tokenURI, uint256 royaltyBasisPoints) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        uint256 royalty = royaltyBasisPoints > 0 ? royaltyBasisPoints : defaultRoyaltyBps;
        require(royalty <= MAX_ROYALTY_BPS, "Royalty exceeds maximum");

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        creators[newTokenId] = msg.sender;
        royaltyBps[newTokenId] = royalty;

        emit NFTMinted(newTokenId, msg.sender, tokenURI);
        emit RoyaltySet(newTokenId, royalty);

        return newTokenId;
    }

    function getPlatformFee(uint256 salePrice) public view returns (address feeRecipient, uint256 platformFeeAmount) {
        return (platformFeeRecipient, (salePrice * platformFeeBps) / 10000);
    }

    function setPlatformFee(uint256 newPlatformFeeBps) public onlyOwner {
        require(newPlatformFeeBps <= 1000, "Platform fee exceeds maximum");
        platformFeeBps = newPlatformFeeBps;
        emit PlatformFeeUpdated(newPlatformFeeBps);
    }

    function setPlatformFeeRecipient(address newPlatformFeeRecipient) public onlyOwner {
        require(newPlatformFeeRecipient != address(0), "Invalid address");
        platformFeeRecipient = newPlatformFeeRecipient;
        emit PlatformFeeRecipientUpdated(newPlatformFeeRecipient);
    }
}

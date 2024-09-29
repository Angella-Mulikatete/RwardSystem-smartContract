// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PlasticContributionNFT is ERC721URIStorage, Ownable {
    // using Counters for Counters.Counter;
    // Counters.Counter private _tokenIds;
    uint256 private _tokenIds;

    enum NFTLevel { Level1, Level2, Level3 } // Levels for different contribution stages

   
    uint256 public constant CONTRIBUTION_THRESHOLD = 4;  // Contribution count required to upgrade to the next level
    mapping(address => uint256) public userContributions; // Mapping to track user contributions
    mapping(uint256 => NFTLevel) public tokenLevel;  // Mapping to store the level of each minted NFT by token ID

    event NFTMinted(address indexed recipient, uint256 tokenId, NFTLevel level);
    event URIUpdated(NFTLevel indexed level, string newURI);
    event ContributionUpdated(address indexed recipient, uint256 newContribution);
    event NFTLevelUpgraded(uint256 indexed tokenId, NFTLevel newLevel);

    error Unauthorized(); // Thrown when the caller is not authorized
    error InvalidTokenId(); // Thrown when a token ID does not exist
    
    string public level1URI = "https://violet-major-ocelot-686.mypinata.cloud/ipfs/QmPjACyCpF2sB6DaYRjWgKToEhspNvSzKGLLJjc3vucYbQ";
    string public level2URI = "https://violet-major-ocelot-686.mypinata.cloud/ipfs/QmPjACyCpF2sB6DaYRjWgKToEhspNvSzKGLLJjc3vucYbQ";
    string public level3URI = "https://violet-major-ocelot-686.mypinata.cloud/ipfs/QmPjACyCpF2sB6DaYRjWgKToEhspNvSzKGLLJjc3vucYbQ";

    constructor() ERC721("PlasticContributionNFT", "PCN") Ownable(msg.sender){}

    // Function for the factory to mint an NFT for a user after a contribution
    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        // _tokenIds.increment();
        // _tokenIds++;

        // uint256 newItemId = _tokenIds.current();
        uint256 newItemId = _tokenIds++;
        
        NFTLevel level = determineLevel(recipient);

        // Assign the appropriate metadata URI based on the user's contribution level
        string memory metadataURI = getTokenURIForLevel(level);
        
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, metadataURI);

        // Update the level and reset contributions if user reaches the next level
        tokenLevel[newItemId] = level;
        updateContributions(recipient);
        emit NFTMinted(recipient, newItemId, level);

        return newItemId;
    }

    // Determine the NFT level based on user contributions
    function determineLevel(address recipient) internal view returns (NFTLevel) {
        uint256 contributions = userContributions[recipient];
        if (contributions >= CONTRIBUTION_THRESHOLD * 2) {
            return NFTLevel.Level3; // Level 3
        } else if (contributions >= CONTRIBUTION_THRESHOLD) {
            return NFTLevel.Level2; // Level 2
        }
        return NFTLevel.Level1; // Level 1
    }

    // Update user contributions and reset if they reach a new level
    function updateContributions(address recipient) internal {
        userContributions[recipient]++;

        emit ContributionUpdated(recipient, userContributions[recipient]);
        
        if (userContributions[recipient] > CONTRIBUTION_THRESHOLD * 2) {
            userContributions[recipient] = 0; // Reset contributions after reaching Level 3
        }
    }

    // Return the appropriate URI for each level
    function getTokenURIForLevel(NFTLevel level) internal view returns (string memory) {
        if (level == NFTLevel.Level1) {
            return level1URI;
        } else if (level == NFTLevel.Level2) {
            return level2URI;
        } else {
            return level3URI;
        }
    }


    function setLevelURIs(
        string memory _level1URI,
        string memory _level2URI,
        string memory _level3URI
    ) public onlyOwner {
        level1URI = _level1URI;
        level2URI = _level2URI;
        level3URI = _level3URI;

        emit URIUpdated(NFTLevel.Level1, _level1URI);
        emit URIUpdated(NFTLevel.Level2, _level2URI);
        emit URIUpdated(NFTLevel.Level3, _level3URI);
    }

    //retrieve the level of an NFT by token ID
    function getNFTLevel(uint256 tokenId) public view returns (NFTLevel) {
        return tokenLevel[tokenId];
    }

    // Override required by Solidity for token URI handling
    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}














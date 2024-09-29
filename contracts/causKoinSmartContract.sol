// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;


import "./nft.sol";
import "./causeKoin.sol";

contract ContributionRewardSystem {
    PlasticContributionNFT public contributionNFT;
    CauseKoin public causeKoin;

    address public owner;

    // Base reward for Level 1 NFT
    uint256 public  LEVEL1_REWARD = 1 * (10 ** 18); // 10 CK tokens
    uint256 public LEVEL2_REWARD = 2 * (10 ** 18); // 20 CK tokens
    uint256 public  LEVEL3_REWARD = 4 * (10 ** 18); // 40 CK tokens

    // Mapping to keep track of which NFTs have been used to claim rewards
    mapping(uint256 => bool) public rewardedNFTs;
    enum NFTLevel { A, B, C }
    mapping(address => NFTLevel) public userLevels;
     mapping(address => uint256) public claimCount;  // Track user claims

    constructor(address _contributionNFTAddress, address _causeKoinAddress) {
        contributionNFT = PlasticContributionNFT(_contributionNFTAddress);
        causeKoin = CauseKoin(_causeKoinAddress);
        owner = msg.sender;
    }

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    // Function to claim rewards based on the NFT level
    function claimRewards(uint256 _tokenId) public {
        // Check if the sender owns the NFT
        require(contributionNFT.ownerOf(_tokenId) == msg.sender, "You do not own this NFT");

        // Check if the NFT has already been used to claim rewards
        require(!rewardedNFTs[_tokenId], "Rewards for this NFT have already been claimed");

        // Determine the NFT level
        PlasticContributionNFT.NFTLevel level = contributionNFT.getNFTLevel(_tokenId);
        
        claimCount[msg.sender] += 1;
        updateUserLevel(msg.sender);

        // Distribute rewards based on the NFT level
        if (level == PlasticContributionNFT.NFTLevel.Level1) {
            causeKoin.transfer(msg.sender, LEVEL1_REWARD);
        } else if (level == PlasticContributionNFT.NFTLevel.Level2) {
            causeKoin.transfer(msg.sender, LEVEL2_REWARD);
        } else if (level == PlasticContributionNFT.NFTLevel.Level3) {
            causeKoin.transfer(msg.sender, LEVEL3_REWARD);
        }

        // Mark the NFT as rewarded
        rewardedNFTs[_tokenId] = true;
    }

    // Function to set the reward amounts (optional)
    function setRewardAmounts(uint256 _level1Reward, uint256 _level2Reward, uint256 _level3Reward) external onlyOwner {
        require(_level1Reward > 0 && _level2Reward > 0 && _level3Reward > 0, "Rewards must be greater than 0");
        LEVEL1_REWARD = _level1Reward;
        LEVEL2_REWARD = _level2Reward;
        LEVEL3_REWARD = _level3Reward;
    }

    function updateUserLevel(address _user) internal  {
        uint256 userClaims = claimCount[_user];
         if (userClaims >= 7) {
            userLevels[_user] = NFTLevel.C; // Level C
        } else if (userClaims > 4) {
            userLevels[_user] = NFTLevel.B; // Level B
        } else {
            userLevels[_user] = NFTLevel.A; // Level A
        }
    }

    // Function to withdraw tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
        causeKoin.transfer(owner, amount);
    }

     function getUserLevel(address _user) external view returns (NFTLevel) {
        return userLevels[_user];
    }

     // View the number of tokens claimed by the user
    function getUserClaimCount(address _user) public view returns (uint256) {
        return claimCount[_user];
    }

     // Get the user's updated token balance in CauseKoin after claiming rewards
    function getUserBalance(address _user) external view returns (uint256) {
        return causeKoin.balanceOf(_user);
    }
}

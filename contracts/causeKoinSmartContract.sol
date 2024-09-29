// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;


import "./nft.sol";
import "./causeKoin.sol";

contract ContributionRewardSystem {
    PlasticContributionNFT public contributionNFT;
    CauseKoin public causeKoin;

    address public owner;

    uint256 public  LEVEL1_REWARD = 1 * (10 ** 18); // 10 CK tokens
    uint256 public LEVEL2_REWARD = 2 * (10 ** 18); // 20 CK tokens
    uint256 public  LEVEL3_REWARD = 4 * (10 ** 18); // 40 CK tokens


    error Unauthorized(string message);           
    error AlreadyClaimed(uint256 tokenId);         
    error InsufficientBalance(uint256 amount);     
    error InvalidAddress(address userAddress);    
    error ZeroAmount();                          

    enum NFTLevel { A, B, C }
     
    mapping(uint256 => bool) public rewardedNFTs; // Mapping to keep track of which NFTs have been used to claim rewards
    mapping(address => NFTLevel) public userLevels;
    mapping(address => uint256) public claimCount;  // Track user claims

    event RewardClaimed(address indexed user, uint256 indexed tokenId,  uint8 nftLevel);
    event RewardAmountUpdated(uint256 level1Reward, uint256 indexed level2Reward, uint256 level3Reward);
    event Withdrawn(address indexed owner, uint256 indexed amount);
    event UserLevelUpdated(address indexed user, NFTLevel indexed newLevel);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor(address _contributionNFTAddress, address _causeKoinAddress) {
        contributionNFT = PlasticContributionNFT(_contributionNFTAddress);
        causeKoin = CauseKoin(_causeKoinAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized("You are not the owner");
        _;
    }

    // Function to claim rewards based on the NFT level
    function claimRewards(uint256 _tokenId) public {
        // Check if the sender owns the NFT
        if (contributionNFT.ownerOf(_tokenId) != msg.sender) {
            revert Unauthorized("You do not own this NFT");
        }

        // Check if the NFT has already been used to claim rewards
        if (rewardedNFTs[_tokenId]) {
            revert AlreadyClaimed(_tokenId);
        }

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
        emit RewardClaimed(msg.sender, _tokenId, uint8(level));
    }

    function setRewardAmounts(uint256 _level1Reward, uint256 _level2Reward, uint256 _level3Reward) external onlyOwner {
        //require(_level1Reward > 0 && _level2Reward > 0 && _level3Reward > 0, "Rewards must be greater than 0");
         if (_level1Reward == 0 || _level2Reward == 0 || _level3Reward == 0) {
            revert ZeroAmount();
        }
        LEVEL1_REWARD = _level1Reward;
        LEVEL2_REWARD = _level2Reward;
        LEVEL3_REWARD = _level3Reward;

        emit RewardAmountUpdated(_level1Reward, _level2Reward, _level3Reward);
    }

    function updateUserLevel(address _user) internal  {
         if (_user == address(0)) {
            revert InvalidAddress(_user);
        }

        uint256 userClaims = claimCount[_user];
         if (userClaims >= 7) {
            userLevels[_user] = NFTLevel.C; 
        } else if (userClaims > 4) {
            userLevels[_user] = NFTLevel.B; 
        } else {
            userLevels[_user] = NFTLevel.A; 
        }

        emit UserLevelUpdated(_user,  userLevels[_user]);
    }

    // Function to withdraw tokens from the contract
    function withdrawTokens(uint256 amount) external onlyOwner {
         if (causeKoin.balanceOf(address(this)) < amount) {
            revert InsufficientBalance(amount);
        }
        
        causeKoin.transfer(owner, amount);
        emit Withdrawn(owner, amount);
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

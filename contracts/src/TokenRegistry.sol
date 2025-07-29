// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TokenFactory.sol";

/**
 * @title TokenRegistry
 * @dev Centralized registry for all deployed ERC20 tokens
 * 
 * This contract provides a comprehensive registry system for token discovery,
 * metadata storage, and search capabilities. It integrates with TokenFactory
 * and provides efficient querying mechanisms.
 * 
 * @author URBE Starter Kit
 * @notice Centralized token registry with discovery and search capabilities
 */
contract TokenRegistry is Ownable, ReentrancyGuard {
    // ============ Structs ============
    
    /// @notice Token metadata structure
    struct TokenMetadata {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 maxSupply;
        address creator;
        uint256 registeredAt;
        string description;
        string website;
        string logo;
        bool verified;
        bool active;
        uint256 category;
        string[] tags;
    }
    
    /// @notice Creator information structure
    struct CreatorInfo {
        address creator;
        uint256 totalTokens;
        uint256 verifiedTokens;
        uint256 totalVolume;
        uint256 lastActivity;
        bool verified;
        string name;
        string description;
    }
    
    /// @notice Category information structure
    struct CategoryInfo {
        string name;
        string description;
        uint256 tokenCount;
        bool active;
    }
    
    // ============ State Variables ============
    
    /// @notice Mapping from token address to token metadata
    mapping(address => TokenMetadata) public tokenMetadata;
    
    /// @notice Mapping from creator address to creator info
    mapping(address => CreatorInfo) public creatorInfo;
    
    /// @notice Mapping from category ID to category info
    mapping(uint256 => CategoryInfo) public categories;
    
    /// @notice Array of all registered tokens
    address[] public allTokens;
    
    /// @notice Array of all creators
    address[] public allCreators;
    
    /// @notice Total number of registered tokens
    uint256 public totalTokensRegistered;
    
    /// @notice Total number of creators
    uint256 public totalCreators;
    
    /// @notice Total number of categories
    uint256 public totalCategories;
    
    /// @notice Registration fee (in wei)
    uint256 public registrationFee;
    
    /// @notice Whether registry is paused
    bool public registryPaused;
    
    /// @notice TokenFactory contract address
    address public tokenFactory;
    
    /// @notice Minimum verification requirements
    uint256 public minTokensForVerification;
    uint256 public minVolumeForVerification;
    
    // ============ Custom Errors ============
    
    /// @notice Error thrown when registry is paused
    error RegistryPaused();
    
    /// @notice Error thrown when token address is invalid
    error InvalidTokenAddress();
    
    /// @notice Error thrown when token is already registered
    error TokenAlreadyRegistered();
    
    /// @notice Error thrown when token is not registered
    error TokenNotRegistered();
    
    /// @notice Error thrown when creator address is invalid
    error InvalidCreatorAddress();
    
    /// @notice Error thrown when category ID is invalid
    error InvalidCategoryId();
    
    /// @notice Error thrown when registration fee is insufficient
    error InsufficientRegistrationFee();
    
    /// @notice Error thrown when name is empty
    error EmptyName();
    
    /// @notice Error thrown when symbol is empty
    error EmptySymbol();
    
    /// @notice Error thrown when description is empty
    error EmptyDescription();
    
    /// @notice Error thrown when only creator can call
    error OnlyCreator();
    
    /// @notice Error thrown when only verified creator can call
    error OnlyVerifiedCreator();
    
    /// @notice Error thrown when index is out of bounds
    error IndexOutOfBounds();
    
    /// @notice Error thrown when token is not verified
    error TokenNotVerified();
    
    // ============ Events ============
    
    /// @notice Emitted when a token is registered
    event TokenRegistered(
        address indexed tokenAddress,
        string name,
        string symbol,
        address indexed creator,
        uint256 category,
        bool verified
    );
    
    /// @notice Emitted when token metadata is updated
    event TokenMetadataUpdated(
        address indexed tokenAddress,
        string name,
        string symbol,
        string description,
        string website,
        string logo
    );
    
    /// @notice Emitted when token verification status changes
    event TokenVerificationUpdated(
        address indexed tokenAddress,
        bool verified,
        address indexed by
    );
    
    /// @notice Emitted when creator is registered
    event CreatorRegistered(
        address indexed creator,
        string name,
        string description
    );
    
    /// @notice Emitted when creator info is updated
    event CreatorInfoUpdated(
        address indexed creator,
        string name,
        string description
    );
    
    /// @notice Emitted when creator verification status changes
    event CreatorVerificationUpdated(
        address indexed creator,
        bool verified,
        address indexed by
    );
    
    /// @notice Emitted when category is created
    event CategoryCreated(
        uint256 indexed categoryId,
        string name,
        string description
    );
    
    /// @notice Emitted when category is updated
    event CategoryUpdated(
        uint256 indexed categoryId,
        string name,
        string description,
        bool active
    );
    
    /// @notice Emitted when registration fee is updated
    event RegistrationFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
    
    /// @notice Emitted when registry is paused/unpaused
    event RegistryPauseToggled(bool paused, address indexed by);
    
    /// @notice Emitted when fees are withdrawn
    event FeesWithdrawn(uint256 amount, address indexed to);
    
    // ============ Constructor ============
    
    /**
     * @notice Initializes the TokenRegistry contract
     * @param initialOwner The initial owner of the registry
     * @param initialRegistrationFee The initial registration fee in wei
     * @param initialTokenFactory The address of the TokenFactory contract
     * @param initialMinTokensForVerification Minimum tokens for creator verification
     * @param initialMinVolumeForVerification Minimum volume for creator verification
     */
    constructor(
        address initialOwner,
        uint256 initialRegistrationFee,
        address initialTokenFactory,
        uint256 initialMinTokensForVerification,
        uint256 initialMinVolumeForVerification
    ) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert InvalidCreatorAddress();
        if (initialTokenFactory == address(0)) revert InvalidTokenAddress();
        
        registrationFee = initialRegistrationFee;
        tokenFactory = initialTokenFactory;
        minTokensForVerification = initialMinTokensForVerification;
        minVolumeForVerification = initialMinVolumeForVerification;
        registryPaused = false;
        
        // Create default categories
        _createCategory("DeFi", "Decentralized Finance tokens");
        _createCategory("Gaming", "Gaming and NFT tokens");
        _createCategory("Infrastructure", "Infrastructure and utility tokens");
        _createCategory("Social", "Social and community tokens");
        _createCategory("Other", "Other miscellaneous tokens");
        
        emit RegistrationFeeUpdated(0, initialRegistrationFee, initialOwner);
    }
    
    // ============ External Functions ============
    
    /**
     * @notice Register a new token with metadata
     * @param tokenAddress The address of the token to register
     * @param description The description of the token
     * @param website The website URL of the token
     * @param logo The logo URL of the token
     * @param category The category ID of the token
     * @param tags Array of tags for the token
     */
    function registerToken(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo,
        uint256 category,
        string[] memory tags
    ) external payable nonReentrant {
        _registerToken(
            tokenAddress,
            description,
            website,
            logo,
            category,
            tags,
            msg.sender
        );
    }
    
    /**
     * @notice Register a token on behalf of a creator
     * @param tokenAddress The address of the token to register
     * @param description The description of the token
     * @param website The website URL of the token
     * @param logo The logo URL of the token
     * @param category The category ID of the token
     * @param tags Array of tags for the token
     * @param creator The creator of the token
     */
    function registerTokenForCreator(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo,
        uint256 category,
        string[] memory tags,
        address creator
    ) external payable nonReentrant {
        _registerToken(
            tokenAddress,
            description,
            website,
            logo,
            category,
            tags,
            creator
        );
    }
    
    /**
     * @notice Update token metadata (only creator can call)
     * @param tokenAddress The address of the token to update
     * @param description The new description
     * @param website The new website URL
     * @param logo The new logo URL
     */
    function updateTokenMetadata(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo
    ) external {
        if (tokenMetadata[tokenAddress].creator != msg.sender) revert OnlyCreator();
        if (!tokenMetadata[tokenAddress].active) revert TokenNotRegistered();
        
        tokenMetadata[tokenAddress].description = description;
        tokenMetadata[tokenAddress].website = website;
        tokenMetadata[tokenAddress].logo = logo;
        
        emit TokenMetadataUpdated(
            tokenAddress,
            tokenMetadata[tokenAddress].name,
            tokenMetadata[tokenAddress].symbol,
            description,
            website,
            logo
        );
    }
    
    /**
     * @notice Register or update creator information
     * @param name The name of the creator
     * @param description The description of the creator
     */
    function registerCreator(
        string memory name,
        string memory description
    ) external {
        if (bytes(name).length == 0) revert EmptyName();
        if (bytes(description).length == 0) revert EmptyDescription();
        
        bool isNewCreator = creatorInfo[msg.sender].creator == address(0);
        
        creatorInfo[msg.sender] = CreatorInfo({
            creator: msg.sender,
            totalTokens: isNewCreator ? 0 : creatorInfo[msg.sender].totalTokens,
            verifiedTokens: isNewCreator ? 0 : creatorInfo[msg.sender].verifiedTokens,
            totalVolume: isNewCreator ? 0 : creatorInfo[msg.sender].totalVolume,
            lastActivity: block.timestamp,
            verified: isNewCreator ? false : creatorInfo[msg.sender].verified,
            name: name,
            description: description
        });
        
        if (isNewCreator) {
            allCreators.push(msg.sender);
            totalCreators++;
        }
        
        emit CreatorRegistered(msg.sender, name, description);
    }
    
    /**
     * @notice Update creator information
     * @param name The new name of the creator
     * @param description The new description of the creator
     */
    function updateCreatorInfo(
        string memory name,
        string memory description
    ) external {
        if (creatorInfo[msg.sender].creator == address(0)) revert InvalidCreatorAddress();
        if (bytes(name).length == 0) revert EmptyName();
        if (bytes(description).length == 0) revert EmptyDescription();
        
        creatorInfo[msg.sender].name = name;
        creatorInfo[msg.sender].description = description;
        creatorInfo[msg.sender].lastActivity = block.timestamp;
        
        emit CreatorInfoUpdated(msg.sender, name, description);
    }
    
    // ============ Owner Functions ============
    
    /**
     * @notice Update registration fee (owner only)
     * @param newFee The new registration fee in wei
     */
    function setRegistrationFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = registrationFee;
        registrationFee = newFee;
        
        emit RegistrationFeeUpdated(oldFee, newFee, msg.sender);
    }
    
    /**
     * @notice Toggle registry pause state (owner only)
     * @param paused Whether to pause or unpause the registry
     */
    function setRegistryPaused(bool paused) external onlyOwner {
        registryPaused = paused;
        
        emit RegistryPauseToggled(paused, msg.sender);
    }
    
    /**
     * @notice Update minimum verification requirements (owner only)
     * @param minTokens Minimum tokens for verification
     * @param minVolume Minimum volume for verification
     */
    function setVerificationRequirements(
        uint256 minTokens,
        uint256 minVolume
    ) external onlyOwner {
        minTokensForVerification = minTokens;
        minVolumeForVerification = minVolume;
    }
    
    /**
     * @notice Verify a token (owner only)
     * @param tokenAddress The address of the token to verify
     * @param verified Whether to verify or unverify the token
     */
    function setTokenVerification(address tokenAddress, bool verified) external onlyOwner {
        if (!tokenMetadata[tokenAddress].active) revert TokenNotRegistered();
        
        tokenMetadata[tokenAddress].verified = verified;
        
        if (verified) {
            creatorInfo[tokenMetadata[tokenAddress].creator].verifiedTokens++;
        } else {
            creatorInfo[tokenMetadata[tokenAddress].creator].verifiedTokens--;
        }
        
        emit TokenVerificationUpdated(tokenAddress, verified, msg.sender);
    }
    
    /**
     * @notice Verify a creator (owner only)
     * @param creator The address of the creator to verify
     * @param verified Whether to verify or unverify the creator
     */
    function setCreatorVerification(address creator, bool verified) external onlyOwner {
        if (creatorInfo[creator].creator == address(0)) revert InvalidCreatorAddress();
        
        creatorInfo[creator].verified = verified;
        
        emit CreatorVerificationUpdated(creator, verified, msg.sender);
    }
    
    /**
     * @notice Create a new category (owner only)
     * @param name The name of the category
     * @param description The description of the category
     */
    function createCategory(string memory name, string memory description) external onlyOwner {
        _createCategory(name, description);
    }
    
    /**
     * @notice Update category information (owner only)
     * @param categoryId The ID of the category to update
     * @param name The new name of the category
     * @param description The new description of the category
     * @param active Whether the category is active
     */
    function updateCategory(
        uint256 categoryId,
        string memory name,
        string memory description,
        bool active
    ) external onlyOwner {
        if (categoryId >= totalCategories) revert InvalidCategoryId();
        
        categories[categoryId].name = name;
        categories[categoryId].description = description;
        categories[categoryId].active = active;
        
        emit CategoryUpdated(categoryId, name, description, active);
    }
    
    /**
     * @notice Withdraw accumulated fees (owner only)
     * @param amount The amount to withdraw
     * @param to The address to send fees to
     */
    function withdrawFees(uint256 amount, address to) external onlyOwner {
        if (to == address(0)) revert InvalidCreatorAddress();
        if (amount > address(this).balance) revert InsufficientRegistrationFee();
        
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert();
        
        emit FeesWithdrawn(amount, to);
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Get token metadata by address
     * @param tokenAddress The address of the token
     * @return metadata The token metadata
     */
    function getTokenMetadata(address tokenAddress) external view returns (TokenMetadata memory metadata) {
        return tokenMetadata[tokenAddress];
    }
    
    /**
     * @notice Get creator information by address
     * @param creator The address of the creator
     * @return info The creator information
     */
    function getCreatorInfo(address creator) external view returns (CreatorInfo memory info) {
        return creatorInfo[creator];
    }
    
    /**
     * @notice Get category information by ID
     * @param categoryId The ID of the category
     * @return info The category information
     */
    function getCategoryInfo(uint256 categoryId) external view returns (CategoryInfo memory info) {
        return categories[categoryId];
    }
    
    /**
     * @notice Get all registered tokens
     * @return tokens Array of all registered token addresses
     */
    function getAllTokens() external view returns (address[] memory tokens) {
        return allTokens;
    }
    
    /**
     * @notice Get all creators
     * @return creators Array of all creator addresses
     */
    function getAllCreators() external view returns (address[] memory creators) {
        return allCreators;
    }
    
    /**
     * @notice Get tokens by creator
     * @param creator The address of the creator
     * @return tokens Array of token addresses by the creator
     */
    function getTokensByCreator(address creator) external view returns (address[] memory tokens) {
        uint256 count = 0;
        address[] memory tempTokens = new address[](allTokens.length);
        
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenMetadata[allTokens[i]].creator == creator) {
                tempTokens[count] = allTokens[i];
                count++;
            }
        }
        
        tokens = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            tokens[i] = tempTokens[i];
        }
    }
    
    /**
     * @notice Get tokens by category
     * @param categoryId The ID of the category
     * @return tokens Array of token addresses in the category
     */
    function getTokensByCategory(uint256 categoryId) external view returns (address[] memory tokens) {
        if (categoryId >= totalCategories) revert InvalidCategoryId();
        
        uint256 count = 0;
        address[] memory tempTokens = new address[](allTokens.length);
        
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenMetadata[allTokens[i]].category == categoryId) {
                tempTokens[count] = allTokens[i];
                count++;
            }
        }
        
        tokens = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            tokens[i] = tempTokens[i];
        }
    }
    
    /**
     * @notice Get verified tokens
     * @return tokens Array of verified token addresses
     */
    function getVerifiedTokens() external view returns (address[] memory tokens) {
        uint256 count = 0;
        address[] memory tempTokens = new address[](allTokens.length);
        
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenMetadata[allTokens[i]].verified) {
                tempTokens[count] = allTokens[i];
                count++;
            }
        }
        
        tokens = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            tokens[i] = tempTokens[i];
        }
    }
    
    /**
     * @notice Get verified creators
     * @return creators Array of verified creator addresses
     */
    function getVerifiedCreators() external view returns (address[] memory creators) {
        uint256 count = 0;
        address[] memory tempCreators = new address[](allCreators.length);
        
        for (uint256 i = 0; i < allCreators.length; i++) {
            if (creatorInfo[allCreators[i]].verified) {
                tempCreators[count] = allCreators[i];
                count++;
            }
        }
        
        creators = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            creators[i] = tempCreators[i];
        }
    }
    
    /**
     * @notice Check if a token is registered
     * @param tokenAddress The address of the token
     * @return registered True if the token is registered
     */
    function isTokenRegistered(address tokenAddress) external view returns (bool registered) {
        return tokenMetadata[tokenAddress].active;
    }
    
    /**
     * @notice Check if a creator is registered
     * @param creator The address of the creator
     * @return registered True if the creator is registered
     */
    function isCreatorRegistered(address creator) external view returns (bool registered) {
        return creatorInfo[creator].creator != address(0);
    }
    
    /**
     * @notice Get total statistics
     * @return totalTokens Total number of registered tokens
     * @return totalCreators Total number of creators
     * @return totalCategories Total number of categories
     * @return verifiedTokens Total number of verified tokens
     * @return verifiedCreators Total number of verified creators
     */
    function getStatistics() external view returns (
        uint256 totalTokens,
        uint256 totalCreators,
        uint256 totalCategories,
        uint256 verifiedTokens,
        uint256 verifiedCreators
    ) {
        totalTokens = totalTokensRegistered;
        totalCreators = this.totalCreators();
        totalCategories = this.totalCategories();
        
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (tokenMetadata[allTokens[i]].verified) {
                verifiedTokens++;
            }
        }
        
        for (uint256 i = 0; i < allCreators.length; i++) {
            if (creatorInfo[allCreators[i]].verified) {
                verifiedCreators++;
            }
        }
    }
    
    // ============ Internal Functions ============
    
    /**
     * @notice Internal function to register a token
     * @param tokenAddress The address of the token to register
     * @param description The description of the token
     * @param website The website URL of the token
     * @param logo The logo URL of the token
     * @param category The category ID of the token
     * @param tags Array of tags for the token
     * @param creator The creator of the token
     */
    function _registerToken(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo,
        uint256 category,
        string[] memory tags,
        address creator
    ) internal {
        // Validation checks
        if (registryPaused) revert RegistryPaused();
        if (tokenAddress == address(0)) revert InvalidTokenAddress();
        if (tokenMetadata[tokenAddress].active) revert TokenAlreadyRegistered();
        if (category >= totalCategories) revert InvalidCategoryId();
        if (msg.value < registrationFee) revert InsufficientRegistrationFee();
        
        // Get token information using low-level calls
        (bool nameSuccess, bytes memory nameData) = tokenAddress.call(
            abi.encodeWithSignature("name()")
        );
        if (!nameSuccess || nameData.length == 0) revert InvalidTokenAddress();
        string memory name = abi.decode(nameData, (string));
        
        (bool symbolSuccess, bytes memory symbolData) = tokenAddress.call(
            abi.encodeWithSignature("symbol()")
        );
        if (!symbolSuccess || symbolData.length == 0) revert InvalidTokenAddress();
        string memory symbol = abi.decode(symbolData, (string));
        
        if (bytes(name).length == 0) revert EmptyName();
        if (bytes(symbol).length == 0) revert EmptySymbol();
        
        // Get additional token info
        uint8 decimals = 18; // Default
        uint256 totalSupply = 0;
        
        (bool decimalsSuccess, bytes memory decimalsData) = tokenAddress.call(
            abi.encodeWithSignature("decimals()")
        );
        if (decimalsSuccess && decimalsData.length > 0) {
            decimals = abi.decode(decimalsData, (uint8));
        }
        
        (bool totalSupplySuccess, bytes memory totalSupplyData) = tokenAddress.call(
            abi.encodeWithSignature("totalSupply()")
        );
        if (totalSupplySuccess && totalSupplyData.length > 0) {
            totalSupply = abi.decode(totalSupplyData, (uint256));
        }
        
        // Create token metadata
        TokenMetadata memory metadata = TokenMetadata({
            tokenAddress: tokenAddress,
            name: name,
            symbol: symbol,
            decimals: decimals,
            totalSupply: totalSupply,
            maxSupply: 0, // Will be updated if available
            creator: creator,
            registeredAt: block.timestamp,
            description: description,
            website: website,
            logo: logo,
            verified: false,
            active: true,
            category: category,
            tags: tags
        });
        
        // Try to get max supply from URBEToken if available
        try URBEToken(tokenAddress).maxSupply() returns (uint256 maxSupply) {
            metadata.maxSupply = maxSupply;
        } catch {
            // Max supply not available, keep as 0
        }
        
        tokenMetadata[tokenAddress] = metadata;
        allTokens.push(tokenAddress);
        totalTokensRegistered++;
        
        // Update creator info
        if (creatorInfo[creator].creator == address(0)) {
            creatorInfo[creator] = CreatorInfo({
                creator: creator,
                totalTokens: 1,
                verifiedTokens: 0,
                totalVolume: 0,
                lastActivity: block.timestamp,
                verified: false,
                name: "",
                description: ""
            });
            allCreators.push(creator);
            totalCreators++;
        } else {
            creatorInfo[creator].totalTokens++;
            creatorInfo[creator].lastActivity = block.timestamp;
        }
        
        emit TokenRegistered(tokenAddress, name, symbol, creator, category, false);
    }
    
    /**
     * @notice Internal function to create a category
     * @param name The name of the category
     * @param description The description of the category
     */
    function _createCategory(string memory name, string memory description) internal {
        uint256 categoryId = totalCategories;
        
        categories[categoryId] = CategoryInfo({
            name: name,
            description: description,
            tokenCount: 0,
            active: true
        });
        
        totalCategories++;
        
        emit CategoryCreated(categoryId, name, description);
    }
    
    // ============ Receive Function ============
    
    /**
     * @notice Allows the contract to receive ETH
     */
    receive() external payable {
        // Contract can receive ETH for registration fees
    }
} 
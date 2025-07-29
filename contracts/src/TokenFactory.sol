// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./URBEToken.sol";

/**
 * @title TokenFactory
 * @dev Factory contract for deploying URBEToken instances
 * 
 * This contract allows users to create their own ERC20 tokens with custom
 * configurations. It tracks all deployed tokens and provides querying
 * functionality for token discovery.
 * 
 * @author URBE Starter Kit
 * @notice Factory pattern implementation for ERC20 token deployment
 */
contract TokenFactory is Ownable, ReentrancyGuard {
    // ============ Structs ============
    
    /// @notice Token metadata structure
    struct TokenInfo {
        address tokenAddress;
        string name;
        string symbol;
        uint256 initialSupply;
        uint256 maxSupply;
        address creator;
        uint256 createdAt;
        bool mintingEnabled;
        bool burningEnabled;
        bool pausingEnabled;
    }
    
    // ============ State Variables ============
    
    /// @notice Mapping from creator address to their deployed tokens
    mapping(address => address[]) public tokensByCreator;
    
    /// @notice Mapping from token address to token info
    mapping(address => TokenInfo) public tokenInfo;
    
    /// @notice Array of all deployed tokens
    address[] public allTokens;
    
    /// @notice Total number of tokens deployed
    uint256 public totalTokensDeployed;
    
    /// @notice Maximum tokens a single creator can deploy
    uint256 public maxTokensPerCreator;
    
    /// @notice Factory deployment fee (in wei)
    uint256 public deploymentFee;
    
    /// @notice Whether factory is paused
    bool public factoryPaused;
    
    // ============ Custom Errors ============
    
    /// @notice Error thrown when factory is paused
    error FactoryPaused();
    
    /// @notice Error thrown when name is empty
    error EmptyName();
    
    /// @notice Error thrown when symbol is empty
    error EmptySymbol();
    
    /// @notice Error thrown when initial supply is zero
    error ZeroInitialSupply();
    
    /// @notice Error thrown when max supply is zero
    error ZeroMaxSupply();
    
    /// @notice Error thrown when initial supply exceeds max supply
    error InitialSupplyExceedsMax();
    
    /// @notice Error thrown when max tokens per creator is exceeded
    error MaxTokensPerCreatorExceeded();
    
    /// @notice Error thrown when deployment fee is insufficient
    error InsufficientDeploymentFee();
    
    /// @notice Error thrown when token address is invalid
    error InvalidTokenAddress();
    
    /// @notice Error thrown when creator has no tokens
    error NoTokensFound();
    
    /// @notice Error thrown when index is out of bounds
    error IndexOutOfBounds();
    
    // ============ Events ============
    
    /// @notice Emitted when a new token is deployed
    event TokenDeployed(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        address indexed creator,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    );
    
    /// @notice Emitted when deployment fee is updated
    event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
    
    /// @notice Emitted when max tokens per creator is updated
    event MaxTokensPerCreatorUpdated(uint256 oldMax, uint256 newMax, address indexed by);
    
    /// @notice Emitted when factory is paused/unpaused
    event FactoryPauseToggled(bool paused, address indexed by);
    
    /// @notice Emitted when fees are withdrawn
    event FeesWithdrawn(uint256 amount, address indexed to);
    
    // ============ Constructor ============
    
    /**
     * @notice Initializes the TokenFactory contract
     * @param initialOwner The initial owner of the factory
     * @param initialDeploymentFee The initial deployment fee in wei
     * @param initialMaxTokensPerCreator The initial max tokens per creator
     */
    constructor(
        address initialOwner,
        uint256 initialDeploymentFee,
        uint256 initialMaxTokensPerCreator
    ) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert InvalidTokenAddress();
        
        deploymentFee = initialDeploymentFee;
        maxTokensPerCreator = initialMaxTokensPerCreator;
        factoryPaused = false;
        
        emit DeploymentFeeUpdated(0, initialDeploymentFee, initialOwner);
        emit MaxTokensPerCreatorUpdated(0, initialMaxTokensPerCreator, initialOwner);
    }
    
    // ============ External Functions ============
    
    /**
     * @notice Deploys a new URBEToken with default configuration
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param initialSupply The initial supply of tokens
     * @param maxSupply The maximum supply of tokens
     * @param mintingEnabled Whether minting is initially enabled
     * @param burningEnabled Whether burning is initially enabled
     * @param pausingEnabled Whether pausing is initially enabled
     * @return tokenAddress The address of the deployed token
     */
    function deployToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    ) external payable nonReentrant returns (address tokenAddress) {
        return _deployToken(
            name,
            symbol,
            initialSupply,
            maxSupply,
            msg.sender,
            mintingEnabled,
            burningEnabled,
            pausingEnabled
        );
    }
    
    /**
     * @notice Deploys a new URBEToken with custom owner
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param initialSupply The initial supply of tokens
     * @param maxSupply The maximum supply of tokens
     * @param tokenOwner The owner of the deployed token
     * @param mintingEnabled Whether minting is initially enabled
     * @param burningEnabled Whether burning is initially enabled
     * @param pausingEnabled Whether pausing is initially enabled
     * @return tokenAddress The address of the deployed token
     */
    function deployTokenWithOwner(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        address tokenOwner,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    ) external payable nonReentrant returns (address tokenAddress) {
        return _deployToken(
            name,
            symbol,
            initialSupply,
            maxSupply,
            tokenOwner,
            mintingEnabled,
            burningEnabled,
            pausingEnabled
        );
    }
    
    // ============ Owner Functions ============
    
    /**
     * @notice Updates the deployment fee (owner only)
     * @param newFee The new deployment fee in wei
     */
    function setDeploymentFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = deploymentFee;
        deploymentFee = newFee;
        
        emit DeploymentFeeUpdated(oldFee, newFee, msg.sender);
    }
    
    /**
     * @notice Updates the max tokens per creator limit (owner only)
     * @param newMax The new maximum tokens per creator
     */
    function setMaxTokensPerCreator(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxTokensPerCreator;
        maxTokensPerCreator = newMax;
        
        emit MaxTokensPerCreatorUpdated(oldMax, newMax, msg.sender);
    }
    
    /**
     * @notice Toggles factory pause state (owner only)
     * @param paused Whether to pause or unpause the factory
     */
    function setFactoryPaused(bool paused) external onlyOwner {
        factoryPaused = paused;
        
        emit FactoryPauseToggled(paused, msg.sender);
    }
    
    /**
     * @notice Withdraws accumulated fees (owner only)
     * @param amount The amount to withdraw
     * @param to The address to send fees to
     */
    function withdrawFees(uint256 amount, address to) external onlyOwner {
        if (to == address(0)) revert InvalidTokenAddress();
        if (amount > address(this).balance) revert InsufficientDeploymentFee();
        
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert();
        
        emit FeesWithdrawn(amount, to);
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Gets all tokens deployed by a specific creator
     * @param creator The address of the creator
     * @return tokens Array of token addresses deployed by the creator
     */
    function getTokensByCreator(address creator) external view returns (address[] memory tokens) {
        return tokensByCreator[creator];
    }
    
    /**
     * @notice Gets the number of tokens deployed by a specific creator
     * @param creator The address of the creator
     * @return count The number of tokens deployed by the creator
     */
    function getTokenCountByCreator(address creator) external view returns (uint256 count) {
        return tokensByCreator[creator].length;
    }
    
    /**
     * @notice Gets token info by address
     * @param tokenAddress The address of the token
     * @return info The token info structure
     */
    function getTokenInfo(address tokenAddress) external view returns (TokenInfo memory info) {
        return tokenInfo[tokenAddress];
    }
    
    /**
     * @notice Gets all deployed tokens
     * @return tokens Array of all deployed token addresses
     */
    function getAllTokens() external view returns (address[] memory tokens) {
        return allTokens;
    }
    
    /**
     * @notice Gets the total number of deployed tokens
     * @return count The total number of deployed tokens
     */
    function getTotalTokensDeployed() external view returns (uint256 count) {
        return totalTokensDeployed;
    }
    
    /**
     * @notice Checks if an address is a token creator
     * @param creator The address to check
     * @return isCreator True if the address has deployed tokens
     */
    function isTokenCreator(address creator) external view returns (bool isCreator) {
        return tokensByCreator[creator].length > 0;
    }
    
    /**
     * @notice Gets tokens by creator with pagination
     * @param creator The address of the creator
     * @param offset The starting index
     * @param limit The maximum number of tokens to return
     * @return tokens Array of token addresses
     * @return total The total number of tokens by this creator
     */
    function getTokensByCreatorPaginated(
        address creator,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory tokens, uint256 total) {
        address[] memory allCreatorTokens = tokensByCreator[creator];
        total = allCreatorTokens.length;
        
        if (offset >= total) {
            return (new address[](0), total);
        }
        
        uint256 endIndex = offset + limit;
        if (endIndex > total) {
            endIndex = total;
        }
        
        uint256 resultLength = endIndex - offset;
        tokens = new address[](resultLength);
        
        for (uint256 i = 0; i < resultLength; i++) {
            tokens[i] = allCreatorTokens[offset + i];
        }
    }
    
    /**
     * @notice Gets token info by creator and index
     * @param creator The address of the creator
     * @param index The index of the token
     * @return info The token info structure
     */
    function getTokenByCreatorAtIndex(address creator, uint256 index) external view returns (TokenInfo memory info) {
        address[] memory creatorTokens = tokensByCreator[creator];
        if (index >= creatorTokens.length) revert IndexOutOfBounds();
        
        return tokenInfo[creatorTokens[index]];
    }
    
    // ============ Internal Functions ============
    
    /**
     * @notice Internal function to deploy a new token
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param initialSupply The initial supply of tokens
     * @param maxSupply The maximum supply of tokens
     * @param tokenOwner The owner of the deployed token
     * @param mintingEnabled Whether minting is initially enabled
     * @param burningEnabled Whether burning is initially enabled
     * @param pausingEnabled Whether pausing is initially enabled
     * @return tokenAddress The address of the deployed token
     */
    function _deployToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        address tokenOwner,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    ) internal returns (address tokenAddress) {
        // Validation checks
        if (factoryPaused) revert FactoryPaused();
        if (bytes(name).length == 0) revert EmptyName();
        if (bytes(symbol).length == 0) revert EmptySymbol();
        if (initialSupply == 0) revert ZeroInitialSupply();
        if (maxSupply == 0) revert ZeroMaxSupply();
        if (initialSupply > maxSupply) revert InitialSupplyExceedsMax();
        if (tokenOwner == address(0)) revert InvalidTokenAddress();
        if (msg.value < deploymentFee) revert InsufficientDeploymentFee();
        
        // Check max tokens per creator limit
        uint256 creatorTokenCount = tokensByCreator[msg.sender].length;
        if (creatorTokenCount >= maxTokensPerCreator) revert MaxTokensPerCreatorExceeded();
        
        // Deploy the token
        URBEToken token = new URBEToken(
            name,
            symbol,
            initialSupply,
            maxSupply,
            tokenOwner,
            mintingEnabled,
            burningEnabled,
            pausingEnabled
        );
        
        tokenAddress = address(token);
        
        // Store token info
        TokenInfo memory info = TokenInfo({
            tokenAddress: tokenAddress,
            name: name,
            symbol: symbol,
            initialSupply: initialSupply,
            maxSupply: maxSupply,
            creator: msg.sender,
            createdAt: block.timestamp,
            mintingEnabled: mintingEnabled,
            burningEnabled: burningEnabled,
            pausingEnabled: pausingEnabled
        });
        
        tokenInfo[tokenAddress] = info;
        tokensByCreator[msg.sender].push(tokenAddress);
        allTokens.push(tokenAddress);
        totalTokensDeployed++;
        
        emit TokenDeployed(
            tokenAddress,
            name,
            symbol,
            initialSupply,
            maxSupply,
            msg.sender,
            mintingEnabled,
            burningEnabled,
            pausingEnabled
        );
    }
    
    // ============ Receive Function ============
    
    /**
     * @notice Allows the contract to receive ETH
     */
    receive() external payable {
        // Contract can receive ETH for deployment fees
    }
} 
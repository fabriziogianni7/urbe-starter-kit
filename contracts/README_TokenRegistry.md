# TokenRegistry - Centralized Token Registry Contract

## Overview

TokenRegistry is a comprehensive centralized registry for all deployed ERC20 tokens that provides token discovery, metadata storage, and search capabilities. It integrates with the TokenFactory contract and provides efficient querying mechanisms for token discovery and management.

## Features

### ✅ Centralized Token Registry
- Register and track all deployed ERC20 tokens
- Store comprehensive token metadata
- Support token discovery and search
- Integration with TokenFactory contract

### ✅ Creator Management
- Register and manage token creators
- Track creator statistics and verification
- Creator profile management
- Creator verification system

### ✅ Category System
- Predefined token categories (DeFi, Gaming, Infrastructure, etc.)
- Custom category creation and management
- Category-based token filtering
- Category statistics tracking

### ✅ Search and Discovery
- Query tokens by creator
- Query tokens by category
- Get verified tokens and creators
- Pagination support for large datasets
- Comprehensive statistics

### ✅ Access Control & Security
- Owner-only administrative functions
- Reentrancy protection
- Input validation and sanitization
- Registration fee system
- Registry pause/unpause functionality

### ✅ Verification System
- Token verification by owner
- Creator verification by owner
- Verification requirements tracking
- Verified token/creator filtering

## Contract Structure

```solidity
contract TokenRegistry is Ownable, ReentrancyGuard {
    // Token metadata structure
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
    
    // Creator information structure
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
    
    // Category information structure
    struct CategoryInfo {
        string name;
        string description;
        uint256 tokenCount;
        bool active;
    }
}
```

## Deployment

### Prerequisites
- Foundry installed
- Environment variables set up
- Private key configured
- TokenFactory deployed (optional)

### Environment Setup
```bash
# Copy environment example
cp env.example .env

# Set your private key
echo "PRIVATE_KEY=your_private_key_here" >> .env

# Set RPC URLs (optional)
echo "MAINNET_RPC_URL=your_mainnet_rpc" >> .env
echo "SEPOLIA_RPC_URL=your_sepolia_rpc" >> .env

# Set TokenFactory address (optional)
echo "TOKEN_FACTORY_ADDRESS=your_factory_address" >> .env
```

### Deployment Commands

#### Default Deployment
```bash
# Deploy with default configuration
forge script script/DeployTokenRegistry.s.sol:DeployTokenRegistry --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

#### Custom Deployment
```bash
# Deploy with custom parameters
forge script script/DeployTokenRegistry.s.sol:DeployTokenRegistry --sig "runCustom(uint256,uint256,uint256)" \
  --rpc-url $SEPOLIA_RPC_URL --broadcast --verify \
  0.02 ether 5 2000
```

#### With Existing TokenFactory
```bash
# Deploy with existing TokenFactory
forge script script/DeployTokenRegistry.s.sol:DeployTokenRegistry --sig "runWithFactory(address)" \
  --rpc-url $SEPOLIA_RPC_URL --broadcast --verify \
  0xYourTokenFactoryAddress
```

### Default Configuration
- **Registration Fee**: 0.01 ETH
- **Min Tokens For Verification**: 3
- **Min Volume For Verification**: 1000 tokens
- **Owner**: Deployer address
- **Default Categories**: 5 (DeFi, Gaming, Infrastructure, Social, Other)

## Usage Examples

### Token Registration

#### Basic Token Registration
```solidity
// Register a token with metadata
string[] memory tags = new string[](2);
tags[0] = "DeFi";
tags[1] = "Yield";

registry.registerToken{value: registrationFee}(
    tokenAddress,
    "A DeFi yield token",
    "https://defi.com",
    "https://defi.com/logo.png",
    0, // DeFi category
    tags
);
```

#### Registration for Different Creator
```solidity
// Register token on behalf of another creator
registry.registerTokenForCreator{value: registrationFee}(
    tokenAddress,
    "A gaming token",
    "https://gaming.com",
    "https://gaming.com/logo.png",
    1, // Gaming category
    tags,
    creatorAddress
);
```

### Creator Management

#### Register Creator
```solidity
// Register creator profile
registry.registerCreator("My Project", "Building the future of DeFi");
```

#### Update Creator Info
```solidity
// Update creator information
registry.updateCreatorInfo("Updated Project", "Updated description");
```

### Token Metadata Updates

#### Update Token Metadata
```solidity
// Only creator can call
registry.updateTokenMetadata(
    tokenAddress,
    "Updated description",
    "https://updated.com",
    "https://updated.com/logo.png"
);
```

### Querying Tokens

#### Get Tokens by Creator
```solidity
// Get all tokens by a specific creator
address[] memory tokens = registry.getTokensByCreator(creatorAddress);

// Get token count by creator
uint256 count = registry.getTokenCountByCreator(creatorAddress);
```

#### Get Tokens by Category
```solidity
// Get all tokens in DeFi category
address[] memory defiTokens = registry.getTokensByCategory(0);

// Get all tokens in Gaming category
address[] memory gamingTokens = registry.getTokensByCategory(1);
```

#### Get Verified Tokens/Creators
```solidity
// Get all verified tokens
address[] memory verifiedTokens = registry.getVerifiedTokens();

// Get all verified creators
address[] memory verifiedCreators = registry.getVerifiedCreators();
```

#### Get Token Information
```solidity
// Get comprehensive token metadata
TokenRegistry.TokenMetadata memory metadata = registry.getTokenMetadata(tokenAddress);

// Access metadata properties
string memory name = metadata.name;
string memory symbol = metadata.symbol;
address creator = metadata.creator;
bool verified = metadata.verified;
```

#### Get Creator Information
```solidity
// Get creator profile
TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(creatorAddress);

// Access creator properties
uint256 totalTokens = info.totalTokens;
uint256 verifiedTokens = info.verifiedTokens;
bool verified = info.verified;
```

#### Get Statistics
```solidity
(
    uint256 totalTokens,
    uint256 totalCreators,
    uint256 totalCategories,
    uint256 verifiedTokens,
    uint256 verifiedCreators
) = registry.getStatistics();
```

### Administrative Functions

#### Update Registration Fee
```solidity
// Only owner can call
registry.setRegistrationFee(0.02 ether);
```

#### Pause/Unpause Registry
```solidity
// Only owner can call
registry.setRegistryPaused(true);  // Pause
registry.setRegistryPaused(false); // Unpause
```

#### Verify Token/Creator
```solidity
// Only owner can call
registry.setTokenVerification(tokenAddress, true);
registry.setCreatorVerification(creatorAddress, true);
```

#### Create Category
```solidity
// Only owner can call
registry.createCategory("New Category", "Category description");
```

#### Update Category
```solidity
// Only owner can call
registry.updateCategory(0, "Updated DeFi", "Updated description", true);
```

#### Withdraw Fees
```solidity
// Only owner can call
registry.withdrawFees(amount, recipientAddress);
```

## Integration Examples

### Frontend Integration (React + Wagmi)
```typescript
import { useContractRead, useContractWrite, useAccount } from 'wagmi';

// Register a token
const { write: registerToken } = useContractWrite({
  address: registryAddress,
  abi: registryABI,
  functionName: 'registerToken',
});

const handleRegisterToken = () => {
  registerToken({
    args: [
      tokenAddress,
      "My DeFi Token",
      "https://mydefi.com",
      "https://mydefi.com/logo.png",
      0, // DeFi category
      ["DeFi", "Yield"]
    ],
    value: registrationFee
  });
};

// Get tokens by creator
const { data: tokens } = useContractRead({
  address: registryAddress,
  abi: registryABI,
  functionName: 'getTokensByCreator',
  args: [account?.address],
});

// Get verified tokens
const { data: verifiedTokens } = useContractRead({
  address: registryAddress,
  abi: registryABI,
  functionName: 'getVerifiedTokens',
});
```

### Smart Contract Integration
```solidity
interface ITokenRegistry {
    function registerToken(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo,
        uint256 category,
        string[] memory tags
    ) external payable;
    
    function getTokensByCreator(address creator) external view returns (address[] memory);
    function getTokenMetadata(address tokenAddress) external view returns (TokenMetadata memory);
    function getVerifiedTokens() external view returns (address[] memory);
}

contract TokenManager {
    ITokenRegistry public registry;
    
    constructor(address _registry) {
        registry = ITokenRegistry(_registry);
    }
    
    function registerMyToken(
        address tokenAddress,
        string memory description,
        string memory website,
        string memory logo
    ) external payable {
        string[] memory tags = new string[](2);
        tags[0] = "DeFi";
        tags[1] = "Yield";
        
        registry.registerToken{value: msg.value}(
            tokenAddress,
            description,
            website,
            logo,
            0, // DeFi category
            tags
        );
    }
    
    function getMyTokens() external view returns (address[] memory) {
        return registry.getTokensByCreator(msg.sender);
    }
}
```

### Integration with TokenFactory
```solidity
contract TokenFactoryWithRegistry {
    TokenFactory public factory;
    TokenRegistry public registry;
    
    constructor(address _factory, address _registry) {
        factory = TokenFactory(_factory);
        registry = TokenRegistry(_registry);
    }
    
    function deployAndRegisterToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        string memory description,
        string memory website,
        string memory logo,
        uint256 category,
        string[] memory tags
    ) external payable returns (address tokenAddress) {
        // Deploy token using factory
        tokenAddress = factory.deployToken{value: factory.deploymentFee()}(
            name,
            symbol,
            initialSupply,
            maxSupply,
            true, true, true
        );
        
        // Register token in registry
        registry.registerToken{value: registry.registrationFee()}(
            tokenAddress,
            description,
            website,
            logo,
            category,
            tags
        );
        
        return tokenAddress;
    }
}
```

## Testing

### Run All Tests
```bash
forge test
```

### Run Specific Test Suite
```bash
forge test --match-contract TokenRegistryTest
```

### Run with Verbose Output
```bash
forge test --match-contract TokenRegistryTest -vv
```

### Test Coverage
```bash
forge coverage --match-contract TokenRegistryTest
```

## Security Considerations

### ✅ Implemented Security Features
- **Reentrancy Protection**: All external functions use `nonReentrant` modifier
- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter validation
- **Custom Errors**: Gas-efficient error handling
- **Pausable Registry**: Emergency stop functionality
- **Fee Management**: Secure fee collection and withdrawal

### ⚠️ Security Best Practices
1. **Private Key Management**: Never commit private keys to version control
2. **Fee Management**: Regularly withdraw accumulated fees
3. **Access Control**: Monitor and rotate administrative access
4. **Emergency Procedures**: Have a plan for using pause functionality
5. **Audit**: Consider professional security audit before mainnet deployment

### 🔒 Access Control Matrix

| Function | Owner | Public |
|----------|-------|--------|
| `registerToken()` | ❌ | ✅ |
| `registerTokenForCreator()` | ❌ | ✅ |
| `updateTokenMetadata()` | ❌ | ✅ (Creator only) |
| `registerCreator()` | ❌ | ✅ |
| `updateCreatorInfo()` | ❌ | ✅ (Creator only) |
| `setRegistrationFee()` | ✅ | ❌ |
| `setRegistryPaused()` | ✅ | ❌ |
| `setTokenVerification()` | ✅ | ❌ |
| `setCreatorVerification()` | ✅ | ❌ |
| `createCategory()` | ✅ | ❌ |
| `updateCategory()` | ✅ | ❌ |
| `withdrawFees()` | ✅ | ❌ |
| `getTokensByCreator()` | ❌ | ✅ |
| `getTokenMetadata()` | ❌ | ✅ |

## Gas Optimization

### ✅ Optimizations Implemented
- **Custom Errors**: Replaced require statements with custom errors
- **Efficient Storage**: Optimized data structures for querying
- **Minimal Storage**: Only essential state variables
- **Batch Operations**: Efficient pagination support
- **Event Optimization**: Indexed parameters for efficient filtering

### 📊 Gas Usage Examples
- **Registry Deployment**: ~3,000,000 gas
- **Token Registration**: ~500,000 gas
- **Creator Registration**: ~100,000 gas
- **Query Operations**: ~10,000-100,000 gas
- **Administrative Functions**: ~30,000-80,000 gas

## Events

### Token Events
```solidity
event TokenRegistered(
    address indexed tokenAddress,
    string name,
    string symbol,
    address indexed creator,
    uint256 category,
    bool verified
);

event TokenMetadataUpdated(
    address indexed tokenAddress,
    string name,
    string symbol,
    string description,
    string website,
    string logo
);

event TokenVerificationUpdated(
    address indexed tokenAddress,
    bool verified,
    address indexed by
);
```

### Creator Events
```solidity
event CreatorRegistered(
    address indexed creator,
    string name,
    string description
);

event CreatorInfoUpdated(
    address indexed creator,
    string name,
    string description
);

event CreatorVerificationUpdated(
    address indexed creator,
    bool verified,
    address indexed by
);
```

### Administrative Events
```solidity
event CategoryCreated(uint256 indexed categoryId, string name, string description);
event CategoryUpdated(uint256 indexed categoryId, string name, string description, bool active);
event RegistrationFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
event RegistryPauseToggled(bool paused, address indexed by);
event FeesWithdrawn(uint256 amount, address indexed to);
```

## Custom Errors

### Error Definitions
```solidity
error RegistryPaused();
error InvalidTokenAddress();
error TokenAlreadyRegistered();
error TokenNotRegistered();
error InvalidCreatorAddress();
error InvalidCategoryId();
error InsufficientRegistrationFee();
error EmptyName();
error EmptySymbol();
error EmptyDescription();
error OnlyCreator();
error OnlyVerifiedCreator();
error IndexOutOfBounds();
error TokenNotVerified();
```

### Error Usage
```solidity
// Instead of require statements
if (registryPaused) revert RegistryPaused();
if (tokenAddress == address(0)) revert InvalidTokenAddress();
if (bytes(name).length == 0) revert EmptyName();
```

## Troubleshooting

### Common Issues

#### "InsufficientRegistrationFee" Error
- **Cause**: Not sending enough ETH for registration fee
- **Solution**: Send the required registration fee with the transaction

#### "TokenAlreadyRegistered" Error
- **Cause**: Token is already registered in the registry
- **Solution**: Use a different token or contact owner to remove existing registration

#### "RegistryPaused" Error
- **Cause**: Registry is paused by owner
- **Solution**: Wait for registry to be unpaused or contact owner

#### "OnlyCreator" Error
- **Cause**: Trying to update token metadata without being the creator
- **Solution**: Only the token creator can update metadata

#### "InvalidTokenAddress" Error
- **Cause**: Token address is invalid or token doesn't implement required functions
- **Solution**: Ensure token is a valid ERC20 with name() and symbol() functions

### Debug Commands
```bash
# Check registry state
cast call <registry> "registrationFee()"
cast call <registry> "registryPaused()"
cast call <registry> "totalTokensRegistered()"
cast call <registry> "totalCreators()"
cast call <registry> "totalCategories()"

# Check token registration
cast call <registry> "isTokenRegistered(address)" <token_address>
cast call <registry> "getTokenMetadata(address)" <token_address>

# Check creator registration
cast call <registry> "isCreatorRegistered(address)" <creator_address>
cast call <registry> "getCreatorInfo(address)" <creator_address>

# Get statistics
cast call <registry> "getStatistics()"
```

## Advanced Usage

### Batch Token Registration
```solidity
function registerMultipleTokens(
    address[] memory tokenAddresses,
    string[] memory descriptions,
    string[] memory websites,
    string[] memory logos,
    uint256[] memory categories,
    string[][] memory tagsArray
) external payable {
    require(tokenAddresses.length == descriptions.length, "Arrays must match");
    require(msg.value >= registrationFee * tokenAddresses.length, "Insufficient fee");
    
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
        registry.registerToken{value: registrationFee}(
            tokenAddresses[i],
            descriptions[i],
            websites[i],
            logos[i],
            categories[i],
            tagsArray[i]
        );
    }
}
```

### Token Discovery by Category
```solidity
function discoverTokensByCategory(uint256 categoryId) external view returns (TokenMetadata[] memory) {
    address[] memory tokenAddresses = registry.getTokensByCategory(categoryId);
    TokenMetadata[] memory tokens = new TokenMetadata[](tokenAddresses.length);
    
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
        tokens[i] = registry.getTokenMetadata(tokenAddresses[i]);
    }
    
    return tokens;
}
```

### Creator Analytics
```solidity
function getCreatorAnalytics(address creator) external view returns (
    uint256 totalTokens,
    uint256 verifiedTokens,
    uint256 totalVolume,
    bool verified,
    uint256 lastActivity
) {
    TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(creator);
    return (
        info.totalTokens,
        info.verifiedTokens,
        info.totalVolume,
        info.verified,
        info.lastActivity
    );
}
```

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run `forge test` to ensure all tests pass
6. Submit a pull request

## Support

For questions or issues:
- Create an issue in the repository
- Check the troubleshooting section
- Review the test files for usage examples 
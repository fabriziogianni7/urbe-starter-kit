# TokenFactory - ERC20 Token Factory Contract

## Overview

TokenFactory is a comprehensive factory contract that allows users to deploy their own ERC20 tokens using the factory pattern. It builds upon the URBEToken contract and provides a complete token creation ecosystem with metadata tracking, access control, and comprehensive querying capabilities.

## Features

### ✅ Factory Pattern Implementation
- Deploy new URBEToken instances
- Track all deployed tokens by creator
- Store comprehensive token metadata
- Support custom token configurations

### ✅ Access Control & Security
- Owner-only administrative functions
- Reentrancy protection
- Input validation and sanitization
- Deployment fee system
- Factory pause/unpause functionality

### ✅ Token Management
- Creator-based token tracking
- Pagination support for large token lists
- Comprehensive token metadata storage
- Token discovery and querying

### ✅ Configuration Options
- Customizable deployment fees
- Configurable max tokens per creator
- Flexible token parameters (mintable, burnable, pausable)
- Custom token ownership

### ✅ Comprehensive Events
- Token deployment events
- Administrative state changes
- Fee management events
- Factory state changes

## Contract Structure

```solidity
contract TokenFactory is Ownable, ReentrancyGuard {
    // Token metadata structure
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
    
    // State variables
    mapping(address => address[]) public tokensByCreator;
    mapping(address => TokenInfo) public tokenInfo;
    address[] public allTokens;
    uint256 public totalTokensDeployed;
    uint256 public maxTokensPerCreator;
    uint256 public deploymentFee;
    bool public factoryPaused;
}
```

## Deployment

### Prerequisites
- Foundry installed
- Environment variables set up
- Private key configured

### Environment Setup
```bash
# Copy environment example
cp env.example .env

# Set your private key
echo "PRIVATE_KEY=your_private_key_here" >> .env

# Set RPC URLs (optional)
echo "MAINNET_RPC_URL=your_mainnet_rpc" >> .env
echo "SEPOLIA_RPC_URL=your_sepolia_rpc" >> .env
```

### Deployment Commands

#### Default Deployment
```bash
# Deploy with default configuration
forge script script/DeployTokenFactory.s.sol:DeployTokenFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

#### Custom Deployment
```bash
# Deploy with custom parameters
forge script script/DeployTokenFactory.s.sol:DeployTokenFactory --sig "runCustom(uint256,uint256)" \
  --rpc-url $SEPOLIA_RPC_URL --broadcast --verify \
  0.02 ether 20
```

### Default Configuration
- **Deployment Fee**: 0.01 ETH
- **Max Tokens Per Creator**: 10
- **Owner**: Deployer address
- **Features**: All enabled by default

## Usage Examples

### Deploying Tokens

#### Basic Token Deployment
```solidity
// Deploy a token with default settings
address tokenAddress = factory.deployToken{value: deploymentFee}(
    "My Token",
    "MTK",
    1000000 * 10**18, // 1M tokens
    10000000 * 10**18, // 10M max supply
    true,  // minting enabled
    true,  // burning enabled
    true   // pausing enabled
);
```

#### Custom Owner Token Deployment
```solidity
// Deploy a token with custom owner
address tokenAddress = factory.deployTokenWithOwner{value: deploymentFee}(
    "My Token",
    "MTK",
    1000000 * 10**18,
    10000000 * 10**18,
    customOwner, // Different owner
    true,
    true,
    true
);
```

### Querying Tokens

#### Get Tokens by Creator
```solidity
// Get all tokens by a specific creator
address[] memory tokens = factory.getTokensByCreator(creatorAddress);

// Get token count by creator
uint256 count = factory.getTokenCountByCreator(creatorAddress);

// Check if address is a creator
bool isCreator = factory.isTokenCreator(address);
```

#### Get Token Information
```solidity
// Get comprehensive token info
TokenFactory.TokenInfo memory info = factory.getTokenInfo(tokenAddress);

// Access token properties
string memory name = info.name;
string memory symbol = info.symbol;
address creator = info.creator;
uint256 createdAt = info.createdAt;
```

#### Pagination Support
```solidity
// Get tokens with pagination
(address[] memory tokens, uint256 total) = factory.getTokensByCreatorPaginated(
    creatorAddress,
    0,    // offset
    10    // limit
);
```

### Administrative Functions

#### Update Deployment Fee
```solidity
// Only owner can call
factory.setDeploymentFee(0.02 ether);
```

#### Update Max Tokens Per Creator
```solidity
// Only owner can call
factory.setMaxTokensPerCreator(20);
```

#### Pause/Unpause Factory
```solidity
// Only owner can call
factory.setFactoryPaused(true);  // Pause
factory.setFactoryPaused(false); // Unpause
```

#### Withdraw Fees
```solidity
// Only owner can call
factory.withdrawFees(amount, recipientAddress);
```

## Integration Examples

### Frontend Integration (React + Wagmi)
```typescript
import { useContractRead, useContractWrite, useAccount } from 'wagmi';

// Deploy a new token
const { write: deployToken } = useContractWrite({
  address: factoryAddress,
  abi: factoryABI,
  functionName: 'deployToken',
});

const handleDeployToken = () => {
  deployToken({
    args: [
      "My Token",
      "MTK", 
      1000000n * 10n**18n,
      10000000n * 10n**18n,
      true,
      true,
      true
    ],
    value: deploymentFee
  });
};

// Get tokens by creator
const { data: tokens } = useContractRead({
  address: factoryAddress,
  abi: factoryABI,
  functionName: 'getTokensByCreator',
  args: [account?.address],
});
```

### Smart Contract Integration
```solidity
interface ITokenFactory {
    function deployToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    ) external payable returns (address tokenAddress);
    
    function getTokensByCreator(address creator) external view returns (address[] memory);
    function getTokenInfo(address tokenAddress) external view returns (TokenInfo memory info);
}

contract TokenDeployer {
    ITokenFactory public factory;
    
    constructor(address _factory) {
        factory = ITokenFactory(_factory);
    }
    
    function deployMyToken() external payable {
        address tokenAddress = factory.deployToken{value: msg.value}(
            "My Token",
            "MTK",
            1000000 * 10**18,
            10000000 * 10**18,
            true,
            true,
            true
        );
        
        // Token is now deployed and ready to use
        URBEToken token = URBEToken(tokenAddress);
        // ... use the token
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
forge test --match-contract TokenFactoryTest
```

### Run with Verbose Output
```bash
forge test --match-contract TokenFactoryTest -vv
```

### Test Coverage
```bash
forge coverage --match-contract TokenFactoryTest
```

## Security Considerations

### ✅ Implemented Security Features
- **Reentrancy Protection**: All external functions use `nonReentrant` modifier
- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter validation
- **Custom Errors**: Gas-efficient error handling
- **Pausable Factory**: Emergency stop functionality
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
| `deployToken()` | ❌ | ✅ |
| `deployTokenWithOwner()` | ❌ | ✅ |
| `setDeploymentFee()` | ✅ | ❌ |
| `setMaxTokensPerCreator()` | ✅ | ❌ |
| `setFactoryPaused()` | ✅ | ❌ |
| `withdrawFees()` | ✅ | ❌ |
| `getTokensByCreator()` | ❌ | ✅ |
| `getTokenInfo()` | ❌ | ✅ |

## Gas Optimization

### ✅ Optimizations Implemented
- **Custom Errors**: Replaced require statements with custom errors
- **Efficient Storage**: Optimized data structures for querying
- **Minimal Storage**: Only essential state variables
- **Batch Operations**: Efficient pagination support
- **Event Optimization**: Indexed parameters for efficient filtering

### 📊 Gas Usage Examples
- **Factory Deployment**: ~2,000,000 gas
- **Token Deployment**: ~3,000,000 gas
- **Query Operations**: ~5,000-50,000 gas
- **Administrative Functions**: ~25,000-50,000 gas

## Events

### Token Deployment Events
```solidity
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
```

### Administrative Events
```solidity
event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
event MaxTokensPerCreatorUpdated(uint256 oldMax, uint256 newMax, address indexed by);
event FactoryPauseToggled(bool paused, address indexed by);
event FeesWithdrawn(uint256 amount, address indexed to);
```

## Custom Errors

### Error Definitions
```solidity
error FactoryPaused();
error EmptyName();
error EmptySymbol();
error ZeroInitialSupply();
error ZeroMaxSupply();
error InitialSupplyExceedsMax();
error MaxTokensPerCreatorExceeded();
error InsufficientDeploymentFee();
error InvalidTokenAddress();
error NoTokensFound();
error IndexOutOfBounds();
```

### Error Usage
```solidity
// Instead of require statements
if (factoryPaused) revert FactoryPaused();
if (bytes(name).length == 0) revert EmptyName();
if (initialSupply == 0) revert ZeroInitialSupply();
```

## Troubleshooting

### Common Issues

#### "InsufficientDeploymentFee" Error
- **Cause**: Not sending enough ETH for deployment fee
- **Solution**: Send the required deployment fee with the transaction

#### "MaxTokensPerCreatorExceeded" Error
- **Cause**: Creator has reached their token limit
- **Solution**: Contact factory owner to increase limit or use different creator

#### "FactoryPaused" Error
- **Cause**: Factory is paused by owner
- **Solution**: Wait for factory to be unpaused or contact owner

#### "EmptyName" or "EmptySymbol" Error
- **Cause**: Providing empty name or symbol
- **Solution**: Provide valid non-empty strings

### Debug Commands
```bash
# Check factory state
cast call <factory> "deploymentFee()"
cast call <factory> "maxTokensPerCreator()"
cast call <factory> "factoryPaused()"
cast call <factory> "totalTokensDeployed()"

# Check creator tokens
cast call <factory> "getTokenCountByCreator(address)" <creator_address>
cast call <factory> "isTokenCreator(address)" <creator_address>

# Get token info
cast call <factory> "getTokenInfo(address)" <token_address>
```

## Advanced Usage

### Batch Token Deployment
```solidity
function deployMultipleTokens(
    string[] memory names,
    string[] memory symbols,
    uint256[] memory initialSupplies,
    uint256[] memory maxSupplies
) external payable {
    require(names.length == symbols.length, "Arrays must match");
    require(msg.value >= deploymentFee * names.length, "Insufficient fee");
    
    for (uint256 i = 0; i < names.length; i++) {
        factory.deployToken{value: deploymentFee}(
            names[i],
            symbols[i],
            initialSupplies[i],
            maxSupplies[i],
            true,
            true,
            true
        );
    }
}
```

### Token Discovery
```solidity
function discoverTokensByCreator(address creator) external view returns (TokenInfo[] memory) {
    address[] memory tokenAddresses = factory.getTokensByCreator(creator);
    TokenInfo[] memory tokens = new TokenInfo[](tokenAddresses.length);
    
    for (uint256 i = 0; i < tokenAddresses.length; i++) {
        tokens[i] = factory.getTokenInfo(tokenAddresses[i]);
    }
    
    return tokens;
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
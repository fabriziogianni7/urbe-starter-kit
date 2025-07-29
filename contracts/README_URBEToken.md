# URBEToken - Comprehensive ERC20 Token Contract

## Overview

URBEToken is a comprehensive ERC20 token contract built with Foundry and OpenZeppelin that implements advanced features including minting, burning, pausing, and role-based access control. The contract follows security best practices and includes comprehensive testing.

## Features

### ✅ Core ERC20 Functionality
- Standard ERC20 token implementation
- 18 decimals precision
- Transfer and approval mechanisms
- Balance tracking

### ✅ Advanced Minting System
- Owner minting capability
- Authorized minter role system
- Configurable minting toggle
- Maximum supply enforcement
- Gas-optimized custom errors

### ✅ Burning Functionality
- User self-burning capability
- Authorized burner role system
- Configurable burning toggle
- Balance validation

### ✅ Pausable Functionality
- Emergency pause/unpause capability
- Authorized pauser role system
- Configurable pausing toggle
- Transfer blocking when paused

### ✅ Role-Based Access Control
- MINTER_ROLE for authorized minting
- BURNER_ROLE for authorized burning
- PAUSER_ROLE for emergency controls
- Owner-only role management

### ✅ Security Features
- Reentrancy protection
- Custom error handling
- Input validation
- Zero address checks
- Balance validation

### ✅ Comprehensive Events
- All state changes are logged
- Indexed parameters for efficient filtering
- Detailed event information

## Contract Structure

```solidity
contract URBEToken is ERC20, Ownable, Pausable, ReentrancyGuard, AccessControl {
    // Constants
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    // State Variables
    uint256 public immutable maxSupply;
    bool public mintingEnabled;
    bool public burningEnabled;
    bool public pausingEnabled;
    
    // Custom Errors
    error MintingDisabled();
    error BurningDisabled();
    error PausingDisabled();
    error MaxSupplyExceeded();
    error ZeroAmount();
    error ZeroAddress();
    error InsufficientBalance();
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
forge script script/DeployURBEToken.s.sol:DeployURBEToken --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

#### Custom Deployment
```bash
# Deploy with custom parameters
forge script script/DeployURBEToken.s.sol:DeployURBEToken --sig "runCustom(string,string,uint256,uint256,bool,bool,bool)" \
  --rpc-url $SEPOLIA_RPC_URL --broadcast --verify \
  "My Token" "MTK" 1000000000000000000000000 10000000000000000000000000 true true true
```

### Default Configuration
- **Name**: "URBE Token"
- **Symbol**: "URBE"
- **Initial Supply**: 1,000,000 tokens (1M)
- **Max Supply**: 10,000,000 tokens (10M)
- **Decimals**: 18
- **Features**: All enabled by default

## Usage Examples

### Minting Tokens

#### Owner Minting
```solidity
// Only the owner can call this
token.mint(recipientAddress, amount);
```

#### Authorized Minter
```solidity
// Grant minter role
token.grantMinterRole(minterAddress);

// Minter can now mint
token.mintByMinter(recipientAddress, amount);
```

### Burning Tokens

#### Self-Burning
```solidity
// User burns their own tokens
token.burn(amount);
```

#### Authorized Burning
```solidity
// Grant burner role
token.grantBurnerRole(burnerAddress);

// Burner can burn from any address
token.burnFrom(targetAddress, amount);
```

### Pausing Functionality

#### Emergency Pause
```solidity
// Grant pauser role
token.grantPauserRole(pauserAddress);

// Pause all transfers
token.pause();

// Unpause transfers
token.unpause();
```

### Role Management

#### Granting Roles
```solidity
// Grant minter role
token.grantMinterRole(address);

// Grant burner role
token.grantBurnerRole(address);

// Grant pauser role
token.grantPauserRole(address);
```

#### Revoking Roles
```solidity
// Revoke minter role
token.revokeMinterRole(address);

// Revoke burner role
token.revokeBurnerRole(address);

// Revoke pauser role
token.revokePauserRole(address);
```

### Feature Toggles

#### Enable/Disable Features
```solidity
// Toggle minting
token.toggleMinting(true/false);

// Toggle burning
token.toggleBurning(true/false);

// Toggle pausing
token.togglePausing(true/false);
```

## Testing

### Run All Tests
```bash
forge test
```

### Run Specific Test Suite
```bash
forge test --match-contract URBETokenTest
```

### Run with Verbose Output
```bash
forge test --match-contract URBETokenTest -vv
```

### Test Coverage
```bash
forge coverage --match-contract URBETokenTest
```

## Security Considerations

### ✅ Implemented Security Features
- **Reentrancy Protection**: All external functions use `nonReentrant` modifier
- **Access Control**: Role-based permissions for sensitive operations
- **Input Validation**: Zero address and amount checks
- **Custom Errors**: Gas-efficient error handling
- **Pausable**: Emergency stop functionality
- **Maximum Supply**: Prevents infinite minting

### ⚠️ Security Best Practices
1. **Private Key Management**: Never commit private keys to version control
2. **Role Management**: Regularly review and rotate role assignments
3. **Emergency Procedures**: Have a plan for using pause functionality
4. **Audit**: Consider professional security audit before mainnet deployment
5. **Upgrades**: Plan for potential upgrade mechanisms if needed

### 🔒 Access Control Matrix

| Function | Owner | Minter | Burner | Pauser | Public |
|----------|-------|--------|--------|--------|--------|
| `mint()` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `mintByMinter()` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `burn()` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `burnFrom()` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `pause()` | ✅ | ❌ | ❌ | ✅ | ❌ |
| `unpause()` | ✅ | ❌ | ❌ | ✅ | ❌ |
| `toggleMinting()` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `toggleBurning()` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `togglePausing()` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `grantMinterRole()` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `revokeMinterRole()` | ✅ | ❌ | ❌ | ❌ | ❌ |

## Gas Optimization

### ✅ Optimizations Implemented
- **Custom Errors**: Replaced require statements with custom errors
- **Immutable Variables**: `maxSupply` is immutable
- **Efficient Events**: Indexed parameters for efficient filtering
- **Minimal Storage**: Only essential state variables
- **Optimized Loops**: No unnecessary loops in functions

### 📊 Gas Usage Examples
- **Deployment**: ~2,500,000 gas
- **Mint (owner)**: ~50,000 gas
- **Mint (minter)**: ~50,000 gas
- **Burn**: ~30,000 gas
- **BurnFrom**: ~35,000 gas
- **Pause/Unpause**: ~25,000 gas
- **Role Grant/Revoke**: ~45,000 gas

## Events

### State Change Events
```solidity
event MintingToggled(bool enabled, address indexed by);
event BurningToggled(bool enabled, address indexed by);
event PausingToggled(bool enabled, address indexed by);
event MaxSupplySet(uint256 maxSupply);
```

### Operation Events
```solidity
event TokensMinted(address indexed to, uint256 amount, address indexed by);
event TokensBurned(address indexed from, uint256 amount, address indexed by);
event TokensBurnedFrom(address indexed from, uint256 amount, address indexed by);
```

## Custom Errors

### Error Definitions
```solidity
error MintingDisabled();
error BurningDisabled();
error PausingDisabled();
error MaxSupplyExceeded();
error ZeroAmount();
error ZeroAddress();
error InsufficientBalance();
```

### Error Usage
```solidity
// Instead of require statements
if (!mintingEnabled) revert MintingDisabled();
if (amount == 0) revert ZeroAmount();
if (to == address(0)) revert ZeroAddress();
```

## Integration Examples

### Frontend Integration (React + Wagmi)
```typescript
import { useContractRead, useContractWrite, useAccount } from 'wagmi';

// Read token info
const { data: name } = useContractRead({
  address: tokenAddress,
  abi: tokenABI,
  functionName: 'name',
});

// Mint tokens
const { write: mint } = useContractWrite({
  address: tokenAddress,
  abi: tokenABI,
  functionName: 'mint',
});

// Check if user is minter
const { data: isMinter } = useContractRead({
  address: tokenAddress,
  abi: tokenABI,
  functionName: 'isMinter',
  args: [account?.address],
});
```

### Smart Contract Integration
```solidity
interface IURBEToken {
    function mint(address to, uint256 amount) external;
    function mintByMinter(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
    function pause() external;
    function unpause() external;
}

contract TokenUser {
    IURBEToken public token;
    
    constructor(address _token) {
        token = IURBEToken(_token);
    }
    
    function mintTokens(address recipient, uint256 amount) external {
        token.mintByMinter(recipient, amount);
    }
}
```

## Troubleshooting

### Common Issues

#### "OwnableUnauthorizedAccount" Error
- **Cause**: Calling owner-only function without owner permissions
- **Solution**: Ensure caller has owner role or use `vm.prank(owner)` in tests

#### "MintingDisabled" Error
- **Cause**: Trying to mint when minting is disabled
- **Solution**: Enable minting with `toggleMinting(true)`

#### "MaxSupplyExceeded" Error
- **Cause**: Trying to mint more than max supply allows
- **Solution**: Check `remainingMintableSupply()` before minting

#### "InsufficientBalance" Error
- **Cause**: Trying to burn more tokens than available
- **Solution**: Check balance before burning

### Debug Commands
```bash
# Check contract state
cast call <contract> "mintingEnabled()"
cast call <contract> "burningEnabled()"
cast call <contract> "pausingEnabled()"
cast call <contract> "remainingMintableSupply()"

# Check roles
cast call <contract> "isMinter(address)" <address>
cast call <contract> "isBurner(address)" <address>
cast call <contract> "isPauser(address)" <address>
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
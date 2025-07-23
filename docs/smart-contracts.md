# Smart Contract Development Guide

This guide covers smart contract development using Foundry for the Web3 Starter Kit.

## Overview

The smart contracts in this project are built using:
- **Solidity 0.8.19+** - Latest stable version with security features
- **Foundry** - Modern smart contract development toolkit
- **OpenZeppelin** - Battle-tested smart contract libraries
- **Hardhat** - Alternative development environment (optional)

## Project Structure

```
contracts/
├── src/                    # Smart contract source files
│   ├── SimpleStorage.sol  # Example storage contract
│   └── interfaces/        # Contract interfaces
├── test/                  # Test files
│   └── SimpleStorage.t.sol
├── script/                # Deployment scripts
│   └── Deploy.s.sol
└── foundry.toml          # Foundry configuration
```

## Getting Started

### 1. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Install Dependencies

```bash
cd contracts
forge install OpenZeppelin/openzeppelin-contracts
```

### 3. Compile Contracts

```bash
forge build
```

### 4. Run Tests

```bash
forge test
```

## Contract Examples

### SimpleStorage Contract

The `SimpleStorage` contract demonstrates basic smart contract patterns:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SimpleStorage is Ownable, ReentrancyGuard {
    // Events
    event ValueStored(address indexed user, uint256 value, uint256 timestamp);
    
    // State variables
    uint256 private _storedValue;
    
    // Custom errors
    error InvalidValue();
    
    function store(uint256 newValue) external onlyOwner nonReentrant {
        if (newValue == 0) revert InvalidValue();
        _storedValue = newValue;
        emit ValueStored(msg.sender, newValue, block.timestamp);
    }
    
    function retrieve() external view returns (uint256) {
        return _storedValue;
    }
}
```

## Key Concepts

### 1. Access Control

Use OpenZeppelin's `Ownable` for simple access control:

```solidity
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    function adminOnly() external onlyOwner {
        // Only owner can call this
    }
}
```

### 2. Security Patterns

#### Reentrancy Protection

```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyContract is ReentrancyGuard {
    function withdraw() external nonReentrant {
        // Protected from reentrancy attacks
    }
}
```

#### Custom Errors

```solidity
error InsufficientBalance();
error InvalidAmount();

function transfer(uint256 amount) external {
    if (amount == 0) revert InvalidAmount();
    if (balance < amount) revert InsufficientBalance();
    // ...
}
```

### 3. Events

Always emit events for important state changes:

```solidity
event ValueUpdated(uint256 oldValue, uint256 newValue, address indexed user);

function updateValue(uint256 newValue) external {
    uint256 oldValue = _value;
    _value = newValue;
    emit ValueUpdated(oldValue, newValue, msg.sender);
}
```

## Testing

### Writing Tests

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;
    address public owner;

    function setUp() public {
        owner = makeAddr("owner");
        vm.prank(owner);
        simpleStorage = new SimpleStorage(owner);
    }

    function test_StoreValue() public {
        vm.prank(owner);
        simpleStorage.store(42);
        assertEq(simpleStorage.retrieve(), 42);
    }
}
```

### Test Commands

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vv

# Run specific test
forge test --match-test test_StoreValue

# Run with gas reporting
forge test --gas-report
```

## Deployment

### Local Development

```bash
# Start local node
anvil

# Deploy to local network
forge script Deploy --rpc-url http://localhost:8545 --broadcast
```

### Testnet Deployment

```bash
# Deploy to Sepolia
forge script Deploy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### Environment Setup

Create a `.env` file in the contracts directory:

```env
DEPLOYER_PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Gas Optimization

### Best Practices

1. **Use `uint256` instead of `uint8`** for storage variables
2. **Pack related variables** in structs
3. **Use events** instead of returning arrays
4. **Batch operations** when possible
5. **Use `unchecked`** for arithmetic where overflow is impossible

### Example

```solidity
// Gas efficient struct packing
struct User {
    uint128 balance;
    uint128 lastUpdate;
    address owner;
}

// Use unchecked for known safe operations
function increment() external {
    unchecked {
        counter++;
    }
}
```

## Security Considerations

### 1. Access Control

- Always implement proper access control
- Use role-based access control for complex permissions
- Consider using OpenZeppelin's `AccessControl`

### 2. Input Validation

- Validate all external inputs
- Use custom errors for better gas efficiency
- Check for zero addresses

### 3. Reentrancy Protection

- Use `nonReentrant` modifier for external calls
- Follow checks-effects-interactions pattern
- Consider using pull over push payments

### 4. Integer Overflow

- Solidity 0.8+ handles overflow automatically
- Use `unchecked` only when you're certain overflow is impossible

## Common Patterns

### 1. Pausable Contracts

```solidity
import "@openzeppelin/contracts/security/Pausable.sol";

contract MyContract is Pausable {
    function importantFunction() external whenNotPaused {
        // Function logic
    }
}
```

### 2. Upgradeable Contracts

```solidity
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyContract is Initializable {
    function initialize() public initializer {
        // Initialization logic
    }
}
```

### 3. Token Contracts

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}
```

## Verification

### Etherscan Verification

```bash
# Verify on Etherscan
forge verify-contract <CONTRACT_ADDRESS> src/SimpleStorage.sol:SimpleStorage \
    --chain-id 11155111 \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

### Manual Verification

1. Compile your contract
2. Get the bytecode and ABI
3. Submit to Etherscan with constructor arguments

## Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [Ethereum Development](https://ethereum.org/developers/)

## Troubleshooting

### Common Issues

1. **Compilation Errors**
   - Check Solidity version compatibility
   - Verify import paths
   - Ensure all dependencies are installed

2. **Test Failures**
   - Check test setup
   - Verify expected revert messages
   - Ensure proper account pranking

3. **Deployment Issues**
   - Verify private key format
   - Check RPC URL connectivity
   - Ensure sufficient gas balance

### Debug Commands

```bash
# Debug specific test
forge test --match-test test_StoreValue -vvv

# Check gas usage
forge test --gas-report

# Run with traces
forge test --verbosity 4
``` 
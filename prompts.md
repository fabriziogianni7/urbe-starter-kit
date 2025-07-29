# Prompts
## Dependencies
```
install all dependencies using the commands in the @Makefile
```

## Smart Contracts
### Create Smart Contract
```
Create a comprehensive ERC20 token contract using Foundry and OpenZeppelin. The contract should:

- Use Solidity 0.8.19+ with latest features
- Inherit from OpenZeppelin's ERC20 implementation
- Include proper access control with Ownable from openzeppelin
- Implement minting functionality with role-based access using openzeppelin contracts
- Accept config flags for mintable, burnable, pausable.
- Use custom errors for gas optimization
- Include comprehensive events for all state changes
- Follow security best practices (reentrancy guards, safe math)
- Include NatSpec documentation for all public functions
- Support both owner minting and authorized minter minting
- Include burn functionality for token destruction
- Implement proper pause/unpause functionality for emergencies using Pausable from open zeppelin

The contract should be placed in `contracts/src/` and follow the project's smart contract patterns from `.cursorrules` and `docs/smart-contracts.md`.

Include:
- Main ERC20 contract
- Interface definitions
- Custom errors
- Events for minting, burning, and role changes
- Comprehensive access control
- Gas optimization techniques
```

#### Token Factory
```
Create a TokenFactory contract that allows users to deploy their own ERC20 tokens. The contract should:

- Use the factory pattern to deploy new ERC20 tokens
- Track all deployed tokens by their creators
- Include proper access control and security measures
- Include events for token creation
- Implement proper error handling with custom errors
- Follow the smart contract patterns from `.cursorrules`
- Include comprehensive testing setup

The factory should:
- Allow users to create tokens with custom names, symbols, and initial supply
- Store metadata about deployed tokens
- Provide functions to query deployed tokens by creator
- Include proper validation for token parameters
- Support different token configurations (mintable, burnable, pausable)

Place in `contracts/src/TokenFactory.sol` with corresponding tests.
```

### Token Management
```
Create a TokenRegistry contract that provides a centralized registry for all deployed tokens. The contract should:

- Maintain a registry of all deployed ERC20 tokens
- Allow token creators to register their tokens
- Provide search and filtering capabilities
- Include metadata storage for tokens
- Implement proper access control
- Use events for all registry operations
- Follow security best practices from `.cursorrules`

Features should include:
- Token registration with metadata
- Token discovery and search
- Creator verification
- Token statistics tracking
- Proper data structures for efficient querying
- Integration with the TokenFactory contract

Include comprehensive tests and documentation.
```

### Token Minting
```
Create a MintingSystem contract that handles token minting and distribution. The contract should:

- Allow authorized minters to mint tokens to specific addresses
- Implement batch minting for efficiency
- Include proper access control with roles
- Use events for all minting operations
- Implement rate limiting and quotas
- Follow security patterns from `.cursorrules`

The system should support:
- Individual minting to specific addresses
- Batch minting to multiple addresses
- Minting quotas and limits
- Emergency pause functionality
- Integration with the main ERC20 token
- Proper validation and error handling

Include comprehensive testing and gas optimization.
```

### Testing
```
Create comprehensive tests for all smart contracts using Foundry. The tests should:

- Cover all contract functions and edge cases
- Test security scenarios and attack vectors
- Include integration tests between contracts
- Use proper mocking and fixtures
- Follow testing patterns from `docs/smart-contracts.md`
- Test gas optimization and efficiency
- Include fuzzing tests for critical functions

Test scenarios should include:
- Token creation and deployment
- Minting and burning operations
- Access control and permissions
- Error conditions and edge cases
- Gas usage optimization
- Integration between TokenFactory, TokenRegistry, and MintingSystem
- Security vulnerability testing

Place tests in `contracts/test/` with proper organization.
```

## UI and web3 integration

### Wallet Integration and Connection

```
Create a comprehensive wallet connection system that integrates Civic authentication with Wagmi. The component should:

- Use Civic's embedded wallet capabilities
- Integrate with Wagmi for Web3 interactions
- Follow the Civic integration patterns from `docs/civic.md`
- Implement proper authentication flow
- Use the Wagmi configuration from `docs/wagmi.md`
- Include proper error handling and user feedback

The system should support:
- Civic authentication with SSO options
- Embedded wallet creation and management
- Automatic connection to Wagmi
- Network switching capabilities
- Balance and token display
- Transaction history
- Proper loading states and error handling

Follow the authentication patterns and error handling from the documentation.
```

### Token Creation
```
Create a React component for token creation using the TokenFactory contract. The component should:

- Use Wagmi hooks for contract interactions
- Follow React patterns from `.cursorrules`
- Implement proper TypeScript types
- Include comprehensive error handling
- Use the Civic authentication system
- Follow UI patterns from `docs/frontend.md`

The interface should include:
- Form for token name, symbol, and initial supply
- Token configuration options (mintable, burnable, pausable)
- Real-time validation and feedback
- Transaction status tracking
- Success/error notifications
- Integration with Civic authentication
- Responsive design with Tailwind CSS

Use proper loading states, error boundaries, and user feedback as specified in the documentation.
```

### Token Management
```
Create a comprehensive dashboard for managing deployed tokens. The component should:

- Display all tokens created by the current user
- Use Wagmi hooks for contract reading
- Implement proper data fetching with React Query
- Follow the component patterns from `.cursorrules`
- Include proper TypeScript types
- Use Civic authentication for user identification

Features should include:
- Token list with metadata display
- Token statistics and analytics
- Quick actions (mint, burn, pause)
- Token search and filtering
- Real-time updates using Wagmi's watch functionality
- Responsive design with proper loading states
- Integration with the TokenRegistry contract

Follow the error handling and loading state patterns from the documentation.
```

### Token Minting
```
Create a minting interface that allows users to mint tokens to others. The component should:

- Use the MintingSystem contract for minting operations
- Implement proper form validation
- Use Wagmi hooks for transaction handling
- Follow the transaction patterns from `docs/wagmi.md`
- Include comprehensive error handling
- Use Civic authentication for user verification

The interface should support:
- Individual minting to specific addresses
- Batch minting to multiple addresses
- Real-time balance checking
- Transaction status tracking
- Gas estimation and optimization
- Success/error notifications
- Integration with the ERC20 token contract

Include proper loading states, error boundaries, and user feedback as specified in the documentation.
```

### Token Discovery/search
```
Create a token discovery page that allows users to find and interact with deployed tokens. The component should:

- Use the TokenRegistry contract for token discovery
- Implement search and filtering functionality
- Use Wagmi hooks for contract interactions
- Follow the React patterns from `.cursorrules`
- Include proper TypeScript types
- Use Civic authentication for user context

Features should include:
- Token search by name, symbol, or creator
- Token filtering by various criteria
- Token details and metadata display
- Quick actions for token interaction
- Pagination for large token lists
- Real-time updates
- Responsive design with proper loading states

Follow the data fetching and caching patterns from the documentation.
```

### Transaction Management and Status
```
Create a transaction management system that handles all Web3 transactions. The component should:

- Use Wagmi hooks for transaction tracking
- Implement proper transaction status handling
- Follow the transaction patterns from `docs/wagmi.md`
- Include comprehensive error handling
- Use React Query for data management
- Follow the component patterns from `.cursorrules`

Features should include:
- Transaction status tracking
- Gas estimation and optimization
- Transaction history display
- Error handling and retry mechanisms
- Success/error notifications
- Transaction receipt display
- Integration with all contract interactions

Include proper loading states, error boundaries, and user feedback as specified in the documentation.
```

### Error Handling and User Feedback
```
Create a comprehensive error handling system for Web3 interactions. The system should:

- Implement error boundaries for React components
- Use proper error handling patterns from `docs/troubleshooting.md`
- Include user-friendly error messages
- Handle network errors and timeouts
- Implement retry mechanisms
- Follow the error handling patterns from `.cursorrules`

The system should handle:
- Contract interaction errors
- Network connection issues
- Transaction failures
- User authentication errors
- Gas estimation failures
- Wallet connection issues

Include proper error logging, user notifications, and recovery mechanisms as specified in the documentation.
```

### Deploy
```
Create deployment scripts and configuration for the complete application. The setup should:

- Follow deployment patterns from `docs/deployment.md`
- Include environment configuration
- Set up proper network configurations
- Include contract deployment scripts
- Configure frontend for different environments
- Follow security best practices

The deployment should include:
- Smart contract deployment to testnet/mainnet
- Frontend deployment configuration
- Environment variable setup
- Network-specific configurations
- Contract address management
- Security considerations

Follow the deployment procedures and security patterns from the documentation.
```
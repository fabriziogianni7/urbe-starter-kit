# Web3 Starter Kit for Students

A comprehensive starter kit for learning Web3 development with React, Wagmi, Foundry, and Civic authentication.

## 🚀 Quick Start

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Git
- Foundry (for smart contract development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd starter-kit
   ```

2. **Install Foundry** (if not already installed)
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **Install dependencies**
   ```bash
   make install
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Civic client ID and other configurations
   ```

5. **Start development**
   ```bash
   make dev
   ```

## 🔐 Civic Authentication Setup

### 1. Get Your Civic Client ID

1. Visit [Civic Dashboard](https://auth.civic.com)
2. Sign up or log in to your account
3. Create a new application
4. Copy your Client ID

### 2. Configure Environment Variables

Update your `.env` file with your Civic credentials:

```env
VITE_CIVIC_CLIENT_ID=your_civic_client_id_here
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback
```

### 3. Test Civic Integration

```bash
make civic-test
```

The Civic authentication is now integrated and ready to use! Users can:
- Sign in with Google, Apple, X, Facebook, Discord, GitHub
- Use email authentication
- Access embedded wallet capabilities
- Connect across multiple blockchains

## 📁 Project Structure

```
starter-kit/
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/      # React components
│   │   │   ├── civic/      # Civic authentication components
│   │   │   ├── layout/     # Layout components
│   │   │   └── web3/       # Web3-specific components
│   │   ├── hooks/          # Custom React hooks
│   │   ├── pages/          # Page components
│   │   ├── utils/          # Utility functions
│   │   ├── wagmi/          # Wagmi configuration
│   │   └── styles/         # Global styles
│   ├── public/             # Static assets
│   ├── package.json        # Frontend dependencies
│   ├── vite.config.ts      # Vite configuration
│   ├── tailwind.config.js  # Tailwind CSS configuration
│   └── index.html          # Main HTML file
├── contracts/               # Smart contracts
│   ├── src/                # Solidity contracts
│   │   └── SimpleStorage.sol
│   ├── test/               # Contract tests
│   │   └── SimpleStorage.t.sol
│   ├── script/             # Deployment scripts
│   │   └── Deploy.s.sol
│   └── foundry.toml        # Foundry configuration
├── docs/                   # Documentation
│   ├── smart-contracts.md  # Smart contract guide
│   ├── frontend.md         # Frontend development guide
│   ├── civic.md           # Civic authentication guide
│   ├── deployment.md       # Deployment guide
│   └── troubleshooting.md  # Troubleshooting guide
├── .cursorrules            # Cursor AI context
├── Makefile               # Build automation
├── env.example            # Environment variables template
└── README.md              # This file
```

## 🛠️ Available Commands

### Development
- `make install` - Install all dependencies
- `make dev` - Start development server
- `make build` - Build for production
- `make test` - Run all tests
- `make lint` - Run linting

### Smart Contracts
- `make compile` - Compile smart contracts
- `make test-contracts` - Test smart contracts
- `make deploy` - Deploy contracts to local network
- `make deploy-sepolia` - Deploy to Sepolia testnet

### Civic Authentication
- `make civic-setup` - Set up Civic authentication
- `make civic-test` - Test Civic integration

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Civic Authentication
VITE_CIVIC_CLIENT_ID=your_civic_client_id
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback

# Blockchain Configuration
VITE_CHAIN_ID=11155111  # Sepolia testnet
VITE_RPC_URL=https://sepolia.infura.io/v3/your_project_id

# Contract Addresses (will be populated after deployment)
VITE_CONTRACT_ADDRESS=
```

### Civic Setup

1. Go to [Civic Dashboard](https://auth.civic.com)
2. Create a new application
3. Add your redirect URI: `http://localhost:3000/auth/callback`
4. Copy your Client ID to `.env`

## 📚 Learning Path

### 1. Understanding the Stack
- **React**: Frontend framework
- **Wagmi**: React hooks for Ethereum
- **Foundry**: Smart contract development toolkit
- **Civic**: Web3 authentication with SSO and embedded wallets

### 2. Smart Contract Development
- Start with `contracts/src/SimpleStorage.sol`
- Learn about state variables, functions, and events
- Run tests with `make test-contracts`

### 3. Frontend Integration
- Explore `frontend/src/components/` for examples
- Learn Wagmi hooks in `frontend/src/hooks/`
- Understand Civic authentication flow

### 4. Advanced Topics
- Custom hooks for Web3 interactions
- Error handling and user experience
- Gas optimization
- Security best practices

## 🧪 Testing

### Frontend Tests
```bash
make test-frontend
```

### Smart Contract Tests
```bash
make test-contracts
```

### Integration Tests
```bash
make test-integration
```

## 🚀 Deployment

### Smart Contracts
1. Configure your deployment network in `foundry.toml`
2. Set your private key in environment variables
3. Run `make deploy-sepolia`

### Frontend
1. Build the application: `make build`
2. Deploy to your preferred hosting service
3. Update environment variables for production

## 📖 Documentation

- [Smart Contract Guide](./docs/smart-contracts.md)
- [Frontend Development](./docs/frontend.md)
- [Civic Integration](./docs/civic.md)
- [Deployment Guide](./docs/deployment.md)
- [Troubleshooting](./docs/troubleshooting.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- Check the [troubleshooting guide](./docs/troubleshooting.md)
- Open an issue for bugs or feature requests
- Join our Discord community

## 🎯 Learning Objectives

By the end of this starter kit, you should be able to:

- ✅ Set up a complete Web3 development environment
- ✅ Write and deploy smart contracts with Foundry
- ✅ Build React applications with Wagmi
- ✅ Implement Web3 authentication with Civic (SSO + embedded wallets)
- ✅ Handle user interactions with blockchain
- ✅ Test smart contracts and frontend applications
- ✅ Deploy applications to testnets and mainnet

---

**Happy Building! 🚀** 
# Deployment Guide

This guide covers deploying the Web3 Starter Kit to various environments.

## Overview

The project can be deployed to:
- **Local Development** - For testing and development
- **Testnet** - For testing on public testnets
- **Production** - For live applications

## Prerequisites

### Required Tools

1. **Node.js** (v18 or higher)
2. **Git** for version control
3. **Foundry** for smart contract deployment
4. **Wallet** with testnet/mainnet funds

### Required Accounts

1. **Infura/Alchemy** account for RPC endpoints
2. **Etherscan** account for contract verification
3. **Civic** account for authentication
4. **Hosting provider** (Vercel, Netlify, etc.)

## Environment Setup

### 1. Environment Variables

Create environment-specific `.env` files:

```bash
# Development
cp env.example .env.development

# Production
cp env.example .env.production
```

### 2. Configuration Files

#### Development Environment

```env
# Civic Authentication
VITE_CIVIC_CLIENT_ID=your_dev_civic_client_id
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback

# Blockchain
VITE_CHAIN_ID=11155111
VITE_RPC_URL=https://sepolia.infura.io/v3/your_project_id

# Contract
VITE_CONTRACT_ADDRESS=your_deployed_contract_address

# Development
VITE_DEBUG_MODE=true
VITE_ENABLE_DEV_TOOLS=true
```

#### Production Environment

```env
# Civic Authentication
VITE_CIVIC_CLIENT_ID=your_prod_civic_client_id
VITE_CIVIC_REDIRECT_URI=https://yourdomain.com/auth/callback

# Blockchain
VITE_CHAIN_ID=1
VITE_RPC_URL=https://mainnet.infura.io/v3/your_project_id

# Contract
VITE_CONTRACT_ADDRESS=your_production_contract_address

# Production
VITE_DEBUG_MODE=false
VITE_ENABLE_DEV_TOOLS=false
```

## Smart Contract Deployment

### 1. Local Development

```bash
# Start local blockchain
anvil

# Deploy contracts
make deploy
```

### 2. Testnet Deployment

#### Sepolia Testnet

```bash
# Set environment variables
export DEPLOYER_PRIVATE_KEY=your_private_key
export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
export ETHERSCAN_API_KEY=your_etherscan_api_key

# Deploy to Sepolia
make deploy-sepolia
```

#### Goerli Testnet

```bash
# Deploy to Goerli
forge script Deploy --rpc-url https://goerli.infura.io/v3/your_project_id --broadcast --verify
```

### 3. Mainnet Deployment

```bash
# Set mainnet environment variables
export DEPLOYER_PRIVATE_KEY=your_mainnet_private_key
export MAINNET_RPC_URL=https://mainnet.infura.io/v3/your_project_id
export ETHERSCAN_API_KEY=your_etherscan_api_key

# Deploy to mainnet
forge script Deploy --rpc-url $MAINNET_RPC_URL --broadcast --verify
```

### 4. Contract Verification

```bash
# Verify on Etherscan
forge verify-contract <CONTRACT_ADDRESS> src/SimpleStorage.sol:SimpleStorage \
  --chain-id 11155111 \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address)" <DEPLOYER_ADDRESS>)
```

## Frontend Deployment

### 1. Build for Production

```bash
# Install dependencies
make install

# Build frontend
make build
```

### 2. Vercel Deployment

#### Setup

1. Install Vercel CLI:
   ```bash
   npm install -g vercel
   ```

2. Login to Vercel:
   ```bash
   vercel login
   ```

3. Deploy:
   ```bash
   vercel --prod
   ```

#### Configuration

Create `vercel.json`:

```json
{
  "buildCommand": "make build",
  "outputDirectory": "frontend/dist",
  "installCommand": "make install",
  "framework": "vite",
  "env": {
    "VITE_CIVIC_CLIENT_ID": "@civic_client_id",
    "VITE_RPC_URL": "@rpc_url",
    "VITE_CONTRACT_ADDRESS": "@contract_address"
  }
}
```

### 3. Netlify Deployment

#### Setup

1. Connect your repository to Netlify
2. Configure build settings:
   - **Build command**: `make build`
   - **Publish directory**: `frontend/dist`
   - **Install command**: `make install`

#### Environment Variables

Set in Netlify dashboard:
- `VITE_CIVIC_CLIENT_ID`
- `VITE_RPC_URL`
- `VITE_CONTRACT_ADDRESS`

### 4. Docker Deployment

#### Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Docker Compose

```yaml
version: '3.8'
services:
  web3-starter-kit:
    build: .
    ports:
      - "80:80"
    environment:
      - VITE_CIVIC_CLIENT_ID=${VITE_CIVIC_CLIENT_ID}
      - VITE_RPC_URL=${VITE_RPC_URL}
      - VITE_CONTRACT_ADDRESS=${VITE_CONTRACT_ADDRESS}
```

### 5. AWS Deployment

#### S3 + CloudFront

1. **Create S3 bucket**:
   ```bash
   aws s3 mb s3://your-web3-app
   ```

2. **Upload build files**:
   ```bash
   aws s3 sync frontend/dist s3://your-web3-app
   ```

3. **Configure CloudFront**:
   - Create distribution
   - Set S3 as origin
   - Configure custom domain

#### Environment Variables

Set in AWS Systems Manager Parameter Store:
```bash
aws ssm put-parameter --name "/web3-app/civic-client-id" --value "your_client_id" --type "SecureString"
aws ssm put-parameter --name "/web3-app/rpc-url" --value "your_rpc_url" --type "SecureString"
```

## Post-Deployment

### 1. Update Civic Dashboard

1. Go to [Civic Dashboard](https://dashboard.civic.com)
2. Update your application settings:
   - Change redirect URI to production URL
   - Update allowed origins
   - Configure CORS settings

### 2. Update Contract Addresses

After deploying contracts, update your environment variables:

```env
VITE_CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890
```

### 3. Verify Deployment

#### Frontend Checks

1. **Load the application**
2. **Test Civic authentication**
3. **Test wallet connection**
4. **Test contract interactions**
5. **Check console for errors**

#### Contract Checks

1. **Verify on Etherscan**
2. **Test contract functions**
3. **Check gas usage**
4. **Verify events are emitted**

### 4. Monitoring

#### Frontend Monitoring

```typescript
// Add error tracking
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: "your_sentry_dsn",
  environment: process.env.NODE_ENV,
});
```

#### Contract Monitoring

```bash
# Monitor contract events
forge script Monitor --rpc-url $RPC_URL

# Check gas usage
forge test --gas-report
```

## Security Considerations

### 1. Environment Variables

- Never commit private keys to version control
- Use different keys for development and production
- Rotate keys regularly

### 2. HTTPS

- Always use HTTPS in production
- Configure SSL certificates
- Set up HSTS headers

### 3. CORS

- Configure CORS properly
- Limit allowed origins
- Use secure headers

### 4. Contract Security

- Audit contracts before mainnet deployment
- Use multi-sig wallets for admin functions
- Implement proper access controls

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Clear cache
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Deployment Failures**
   ```bash
   # Check logs
   vercel logs
   netlify logs
   ```

3. **Contract Deployment Issues**
   ```bash
   # Check gas price
   cast gas-price --rpc-url $RPC_URL
   
   # Check balance
   cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL
   ```

4. **Authentication Issues**
   - Verify Civic client ID
   - Check redirect URI configuration
   - Ensure HTTPS in production

### Debug Commands

```bash
# Check deployment status
make status

# Verify contracts
make verify

# Test deployment
make test-deployment

# Monitor logs
make logs
```

## CI/CD Pipeline

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: make install
        
      - name: Run tests
        run: make test
        
      - name: Build
        run: make build
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

## Performance Optimization

### 1. Frontend Optimization

```typescript
// Code splitting
const LazyComponent = lazy(() => import('./LazyComponent'));

// Bundle analysis
npm run build -- --analyze
```

### 2. Contract Optimization

```solidity
// Gas optimization
function optimizedFunction() external {
    // Use unchecked for known safe operations
    unchecked {
        counter++;
    }
}
```

## Backup and Recovery

### 1. Database Backup

```bash
# Backup environment variables
cp .env .env.backup

# Backup contracts
cp contracts/out contracts/out.backup
```

### 2. Recovery Procedures

```bash
# Restore from backup
cp .env.backup .env
cp contracts/out.backup contracts/out

# Redeploy if needed
make deploy
```

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Netlify Documentation](https://docs.netlify.com/)
- [AWS Documentation](https://aws.amazon.com/documentation/)
- [Foundry Book](https://book.getfoundry.sh/)
- [Etherscan API](https://docs.etherscan.io/) 
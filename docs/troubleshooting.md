# Troubleshooting Guide

This guide helps you resolve common issues when working with the Web3 Starter Kit.

## Quick Diagnosis

### Check System Requirements

```bash
# Check Node.js version
node --version  # Should be 18+

# Check npm version
npm --version

# Check Foundry installation
forge --version

# Check Git
git --version
```

### Check Project Status

```bash
# Check if all dependencies are installed
make install

# Check if contracts compile
make compile

# Check if tests pass
make test
```

## Common Issues

### 1. Installation Issues

#### Problem: `npm install` fails

**Symptoms:**
- Error messages about missing dependencies
- Permission errors
- Network timeouts

**Solutions:**

1. **Clear npm cache:**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Use different npm registry:**
   ```bash
   npm config set registry https://registry.npmjs.org/
   npm install
   ```

3. **Check Node.js version:**
   ```bash
   node --version
   # If < 18, update Node.js
   ```

#### Problem: Foundry installation fails

**Symptoms:**
- `forge: command not found`
- Installation script errors

**Solutions:**

1. **Install Foundry manually:**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Add to PATH:**
   ```bash
   export PATH="$PATH:$HOME/.foundry/bin"
   ```

3. **Verify installation:**
   ```bash
   forge --version
   cast --version
   anvil --version
   ```

### 2. Environment Configuration

#### Problem: Environment variables not working

**Symptoms:**
- `undefined` values in app
- Configuration errors
- Missing environment variables

**Solutions:**

1. **Check .env file:**
   ```bash
   # Ensure .env exists
   ls -la .env
   
   # Check file contents
   cat .env
   ```

2. **Verify variable names:**
   ```bash
   # All Vite variables should start with VITE_
   grep "VITE_" .env
   ```

3. **Restart development server:**
   ```bash
   # Stop server (Ctrl+C)
   # Restart
   make dev
   ```

#### Problem: Civic authentication not working

**Symptoms:**
- Login button doesn't work
- Redirect errors
- Authentication failures

**Solutions:**

1. **Check Civic configuration:**
   ```bash
   # Verify client ID
   echo $VITE_CIVIC_CLIENT_ID
   
   # Check redirect URI
   echo $VITE_CIVIC_REDIRECT_URI
   ```

2. **Update Civic dashboard:**
   - Go to [Civic Dashboard](https://dashboard.civic.com)
   - Verify redirect URI matches your app
   - Check allowed origins

3. **Test Civic connection:**
   ```bash
   # Check if Civic service is reachable
   curl https://api.civic.com/health
   ```

### 3. Smart Contract Issues

#### Problem: Contracts won't compile

**Symptoms:**
- Compilation errors
- Missing dependencies
- Solidity version issues

**Solutions:**

1. **Check Solidity version:**
   ```bash
   # In foundry.toml
   solc_version = "0.8.19"
   ```

2. **Install dependencies:**
   ```bash
   cd contracts
   forge install OpenZeppelin/openzeppelin-contracts
   ```

3. **Clean and rebuild:**
   ```bash
   forge clean
   forge build
   ```

#### Problem: Contract deployment fails

**Symptoms:**
- Deployment script errors
- Gas estimation failures
- Network connection issues

**Solutions:**

1. **Check network connection:**
   ```bash
   # Test RPC connection
   cast block-number --rpc-url $RPC_URL
   ```

2. **Check account balance:**
   ```bash
   # Check deployer balance
   cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL
   ```

3. **Check gas price:**
   ```bash
   # Get current gas price
   cast gas-price --rpc-url $RPC_URL
   ```

4. **Increase gas limit:**
   ```bash
   # In deployment script
   forge script Deploy --rpc-url $RPC_URL --broadcast --gas-limit 500000
   ```

#### Problem: Contract verification fails

**Symptoms:**
- Etherscan verification errors
- Constructor arguments issues
- Compiler version mismatch

**Solutions:**

1. **Check constructor arguments:**
   ```bash
   # Encode constructor arguments
   cast abi-encode "constructor(address)" $DEPLOYER_ADDRESS
   ```

2. **Verify compiler version:**
   ```bash
   # Use same compiler version as deployment
   forge verify-contract $CONTRACT_ADDRESS src/SimpleStorage.sol:SimpleStorage \
     --chain-id 11155111 \
     --compiler-version 0.8.19
   ```

3. **Manual verification:**
   - Go to Etherscan
   - Use "Contract" tab
   - Verify manually with source code

### 4. Frontend Issues

#### Problem: React app won't start

**Symptoms:**
- `npm run dev` fails
- Port already in use
- Module resolution errors

**Solutions:**

1. **Check port availability:**
   ```bash
   # Kill process on port 3000
   lsof -ti:3000 | xargs kill -9
   
   # Or use different port
   npm run dev -- --port 3001
   ```

2. **Clear cache:**
   ```bash
   # Clear Vite cache
   rm -rf node_modules/.vite
   npm run dev
   ```

3. **Check TypeScript errors:**
   ```bash
   # Run type check
   npm run type-check
   ```

#### Problem: Wagmi connection issues

**Symptoms:**
- Wallet won't connect
- Network switching problems
- RPC errors

**Solutions:**

1. **Check RPC URL:**
   ```bash
   # Test RPC connection
   curl -X POST -H "Content-Type: application/json" \
     --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
     $VITE_RPC_URL
   ```

2. **Update Wagmi config:**
   ```typescript
   // Check chain configuration
   const config = createConfig({
     chains: [mainnet, sepolia],
     connectors: [injected(), walletConnect({ projectId })],
     transports: {
       [mainnet.id]: http(),
       [sepolia.id]: http(process.env.VITE_RPC_URL),
     },
   });
   ```

3. **Check wallet connection:**
   ```typescript
   // Debug wallet connection
   const { address, isConnected, connector } = useAccount();
   console.log('Wallet status:', { address, isConnected, connector });
   ```

#### Problem: Build errors

**Symptoms:**
- `npm run build` fails
- Bundle size too large
- Missing dependencies

**Solutions:**

1. **Check bundle size:**
   ```bash
   # Analyze bundle
   npm run build -- --analyze
   ```

2. **Fix missing dependencies:**
   ```bash
   # Install missing packages
   npm install missing-package
   ```

3. **Update Vite config:**
   ```typescript
   // Optimize build
   export default defineConfig({
     build: {
       rollupOptions: {
         output: {
           manualChunks: {
             vendor: ['react', 'react-dom'],
             wagmi: ['wagmi', '@wagmi/core'],
           },
         },
       },
     },
   });
   ```

### 5. Testing Issues

#### Problem: Tests fail

**Symptoms:**
- Test suite errors
- Mock failures
- Network issues in tests

**Solutions:**

1. **Run tests with verbose output:**
   ```bash
   # Frontend tests
   npm test -- --verbose
   
   # Contract tests
   forge test -vvv
   ```

2. **Check test environment:**
   ```bash
   # Ensure test environment is set
   NODE_ENV=test npm test
   ```

3. **Update test mocks:**
   ```typescript
   // Update mock implementations
   jest.mock('wagmi', () => ({
     useAccount: () => ({
       address: '0x123...',
       isConnected: true,
     }),
   }));
   ```

#### Problem: Contract tests fail

**Symptoms:**
- Foundry test errors
- Gas estimation failures
- State issues

**Solutions:**

1. **Run tests with gas reporting:**
   ```bash
   forge test --gas-report
   ```

2. **Check test setup:**
   ```solidity
   // Ensure proper test setup
   function setUp() public {
     owner = makeAddr("owner");
     vm.startPrank(owner);
     simpleStorage = new SimpleStorage(owner);
     vm.stopPrank();
   }
   ```

3. **Debug specific test:**
   ```bash
   # Run specific test
   forge test --match-test test_StoreValue -vvv
   ```

### 6. Performance Issues

#### Problem: Slow development server

**Symptoms:**
- Long startup times
- Slow hot reload
- High memory usage

**Solutions:**

1. **Optimize Vite config:**
   ```typescript
   export default defineConfig({
     optimizeDeps: {
       include: ['react', 'react-dom', 'wagmi'],
     },
     server: {
       hmr: { overlay: false },
     },
   });
   ```

2. **Check system resources:**
   ```bash
   # Monitor system resources
   htop
   
   # Check disk space
   df -h
   ```

3. **Use faster package manager:**
   ```bash
   # Use pnpm instead of npm
   npm install -g pnpm
   pnpm install
   ```

#### Problem: High gas costs

**Symptoms:**
- Expensive transactions
- Gas estimation failures
- Contract optimization needed

**Solutions:**

1. **Optimize contract code:**
   ```solidity
   // Use unchecked for safe operations
   function increment() external {
     unchecked {
       counter++;
     }
   }
   ```

2. **Batch operations:**
   ```solidity
   // Batch multiple operations
   function batchStore(uint256[] calldata values) external {
     for (uint256 i = 0; i < values.length; i++) {
       _store(values[i]);
     }
   }
   ```

3. **Use efficient data structures:**
   ```solidity
   // Pack related data
   struct User {
     uint128 balance;
     uint128 lastUpdate;
     address owner;
   }
   ```

## Debug Commands

### System Information

```bash
# Check system info
uname -a
node --version
npm --version
forge --version

# Check disk space
df -h

# Check memory usage
free -h
```

### Project Status

```bash
# Check project structure
tree -L 3

# Check dependencies
npm list --depth=0

# Check contract compilation
forge build --sizes
```

### Network Diagnostics

```bash
# Test RPC connection
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  $VITE_RPC_URL

# Check gas price
cast gas-price --rpc-url $VITE_RPC_URL

# Check account balance
cast balance $DEPLOYER_ADDRESS --rpc-url $VITE_RPC_URL
```

### Log Analysis

```bash
# Check application logs
npm run dev 2>&1 | tee app.log

# Check build logs
npm run build 2>&1 | tee build.log

# Check test logs
npm test 2>&1 | tee test.log
```

## Getting Help

### 1. Check Documentation

- [README.md](./README.md) - Project overview
- [Smart Contracts](./smart-contracts.md) - Contract development
- [Frontend](./frontend.md) - React development
- [Civic](./civic.md) - Authentication setup
- [Deployment](./deployment.md) - Deployment guide

### 2. Search Issues

```bash
# Search for similar issues
grep -r "error message" . --include="*.log"
grep -r "failed" . --include="*.log"
```

### 3. Community Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Wagmi Documentation](https://wagmi.sh/)
- [Civic Documentation](https://docs.civic.com/)
- [React Documentation](https://react.dev/)

### 4. Create Issue Report

When creating an issue, include:

1. **Environment:**
   ```bash
   node --version
   npm --version
   forge --version
   ```

2. **Error message:**
   ```bash
   # Copy full error message
   ```

3. **Steps to reproduce:**
   ```bash
   # List exact steps
   1. git clone ...
   2. cd starter-kit
   3. make install
   4. make dev
   ```

4. **Expected vs actual behavior:**
   - What you expected to happen
   - What actually happened

## Prevention

### 1. Regular Maintenance

```bash
# Update dependencies
npm update
forge update

# Run tests regularly
make test

# Check for security issues
npm audit
```

### 2. Best Practices

1. **Use version control:**
   ```bash
   git add .
   git commit -m "Fix: description of fix"
   ```

2. **Test before committing:**
   ```bash
   make test
   make lint
   ```

3. **Keep environment updated:**
   ```bash
   # Update Node.js regularly
   # Update Foundry regularly
   foundryup
   ```

### 3. Monitoring

```bash
# Monitor application health
make status

# Check for errors
make logs

# Monitor performance
make perf-check
``` 
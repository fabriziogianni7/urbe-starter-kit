# Wallet Connection System

This guide covers the comprehensive wallet connection system that integrates Civic authentication with Wagmi for seamless Web3 interactions.

## Overview

The wallet connection system provides:
- **Civic Authentication** - SSO and email authentication
- **Embedded Wallet Management** - Create and manage wallets in-app
- **Wagmi Integration** - Seamless Web3 interactions
- **Network Switching** - Multi-chain support
- **Balance Tracking** - Real-time balance monitoring
- **Transaction History** - Complete transaction tracking
- **Error Handling** - Comprehensive error management

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Civic Auth    │    │   Wagmi Config  │    │  Wallet Hooks   │
│                 │    │                 │    │                 │
│ • SSO Login     │    │ • Connectors    │    │ • useAccount    │
│ • Email Auth    │    │ • Chains        │    │ • useBalance    │
│ • UserButton    │    │ • Transports    │    │ • useConnect    │
│ • Embedded      │    │ • Embedded      │    │ • useDisconnect │
│   Wallet        │    │   Wallet        │    │ • useSwitchChain│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Components    │
                    │                 │
                    │ • CivicProvider │
                    │ • WalletConnection│
                    │ • TransactionHistory│
                    │ • WalletPage    │
                    └─────────────────┘
```

## Setup

### 1. Environment Configuration

Add Civic credentials to `frontend/.env`:

```env
VITE_CIVIC_CLIENT_ID=your_civic_client_id_here
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback
VITE_RPC_URL=https://sepolia.infura.io/v3/your_project_id
```

### 2. Install Dependencies

```bash
cd frontend
npm install @civic/auth-web3 wagmi viem @tanstack/react-query
```

### 3. Civic Dashboard Setup

1. Go to [Civic Dashboard](https://auth.civic.com)
2. Create a new application
3. Configure settings:
   - **App Name**: Web3 Starter Kit
   - **Redirect URI**: `http://localhost:3000/auth/callback`
   - **Supported Chains**: Ethereum, Polygon, Arbitrum
4. Enable Embedded Wallet in Settings
5. Copy your Client ID

## Components

### CivicProvider

The main provider that wraps the app with Civic authentication:

```tsx
import { CivicProvider } from '@/components/web3/CivicProvider'

function App() {
  return (
    <CivicProvider>
      <YourApp />
    </CivicProvider>
  )
}
```

**Features:**
- Automatic Civic authentication setup
- Error handling for sign-in/sign-out
- Environment variable validation
- Initial chain configuration

### SimpleWalletConnection

The main wallet connection component:

```tsx
import { SimpleWalletConnection } from '@/components/web3/SimpleWalletConnection'

function WalletPage() {
  return (
    <div>
      <SimpleWalletConnection />
    </div>
  )
}
```

**Features:**
- Civic authentication status
- Wallet creation and connection
- Balance display
- Network switching
- Error handling and user feedback

### TransactionHistory

Component for displaying transaction history:

```tsx
import { TransactionHistory } from '@/components/web3/TransactionHistory'

function WalletPage() {
  return (
    <div>
      <TransactionHistory />
    </div>
  )
}
```

**Features:**
- Transaction fetching and display
- Status tracking (pending, success, failed)
- Gas usage analytics
- Block explorer integration
- Refresh functionality

## Hooks

### useWalletTransactions

Custom hook for managing wallet transactions:

```tsx
import { useWalletTransactions } from '@/hooks/useWalletTransactions'

function MyComponent() {
  const { 
    transactions, 
    isLoading, 
    error, 
    fetchTransactions,
    addTransaction,
    updateTransactionStatus 
  } = useWalletTransactions()

  return (
    <div>
      {transactions.map(tx => (
        <div key={tx.hash}>
          {tx.hash} - {tx.status}
        </div>
      ))}
    </div>
  )
}
```

**Features:**
- Automatic transaction fetching
- Transaction status management
- Error handling
- Loading states
- Transaction history persistence

## Wagmi Configuration

The Wagmi configuration includes Civic's embedded wallet:

```tsx
// frontend/src/wagmi/config.ts
import { embeddedWallet } from '@civic/auth-web3/wagmi'

export const config = createConfig({
  chains: [mainnet, sepolia, polygon, arbitrum],
  connectors: [
    embeddedWallet(), // Civic embedded wallet (first priority)
    injected(),
    walletConnect({ projectId }),
    coinbaseWallet({ appName: 'Web3 Starter Kit' }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(process.env.VITE_RPC_URL),
    [polygon.id]: http(),
    [arbitrum.id]: http(),
  },
  ssr: true,
})
```

## Authentication Flow

### 1. User Authentication

```tsx
import { useUser } from '@civic/auth-web3/react'
import { UserButton } from '@civic/auth-web3/react'

function AuthComponent() {
  const { user, authStatus } = useUser()

  return (
    <div>
      <UserButton />
      {authStatus === 'authenticated' && (
        <p>Welcome, {user?.name}!</p>
      )}
    </div>
  )
}
```

### 2. Wallet Creation

```tsx
import { useUser } from '@civic/auth-web3/react'
import { userHasWallet } from '@civic/auth-web3'

function WalletCreation() {
  const userContext = useUser()

  const handleCreateWallet = async () => {
    if (!userHasWallet(userContext)) {
      await userContext.createWallet()
    }
  }

  return (
    <button onClick={handleCreateWallet}>
      Create Wallet
    </button>
  )
}
```

### 3. Wallet Connection

```tsx
import { useConnect } from 'wagmi'

function WalletConnection() {
  const { connect, connectors } = useConnect()

  const handleConnect = () => {
    const civicConnector = connectors.find(c => c.id === 'civic')
    if (civicConnector) {
      connect({ connector: civicConnector })
    }
  }

  return (
    <button onClick={handleConnect}>
      Connect Wallet
    </button>
  )
}
```

## Network Management

### Supported Networks

- **Ethereum Mainnet** - Production network
- **Sepolia Testnet** - Testing network
- **Polygon** - Layer 2 scaling solution
- **Arbitrum** - High-performance L2

### Network Switching

```tsx
import { useSwitchChain } from 'wagmi'
import { mainnet, sepolia, polygon, arbitrum } from 'wagmi/chains'

function NetworkSwitcher() {
  const { switchChain } = useSwitchChain()

  const handleSwitch = async (chainId: number) => {
    try {
      await switchChain({ chainId })
    } catch (error) {
      console.error('Failed to switch network:', error)
    }
  }

  return (
    <div>
      <button onClick={() => handleSwitch(mainnet.id)}>
        Ethereum
      </button>
      <button onClick={() => handleSwitch(sepolia.id)}>
        Sepolia
      </button>
      <button onClick={() => handleSwitch(polygon.id)}>
        Polygon
      </button>
      <button onClick={() => handleSwitch(arbitrum.id)}>
        Arbitrum
      </button>
    </div>
  )
}
```

## Balance Tracking

### Real-time Balance

```tsx
import { useBalance } from 'wagmi'

function BalanceDisplay() {
  const { address } = useAccount()
  const { data: balance, isLoading } = useBalance({
    address,
  })

  if (isLoading) return <div>Loading balance...</div>

  return (
    <div>
      Balance: {balance ? `${balance.formatted} ${balance.symbol}` : '0 ETH'}
    </div>
  )
}
```

### Multi-token Support

```tsx
import { useBalance } from 'wagmi'

function TokenBalance({ tokenAddress }: { tokenAddress: string }) {
  const { address } = useAccount()
  const { data: balance } = useBalance({
    address,
    token: tokenAddress as `0x${string}`,
  })

  return (
    <div>
      Token Balance: {balance?.formatted} {balance?.symbol}
    </div>
  )
}
```

## Transaction Management

### Sending Transactions

```tsx
import { useSendTransaction, usePrepareSendTransaction } from 'wagmi'

function SendTransaction() {
  const { address } = useAccount()
  const { config } = usePrepareSendTransaction({
    to: '0x...',
    value: parseEther('0.1'),
  })
  const { sendTransaction, isLoading } = useSendTransaction(config)

  const handleSend = () => {
    sendTransaction?.()
  }

  return (
    <button onClick={handleSend} disabled={isLoading}>
      {isLoading ? 'Sending...' : 'Send Transaction'}
    </button>
  )
}
```

### Transaction History

```tsx
import { useWalletTransactions } from '@/hooks/useWalletTransactions'

function TransactionList() {
  const { transactions, isLoading } = useWalletTransactions()

  if (isLoading) return <div>Loading transactions...</div>

  return (
    <div>
      {transactions.map(tx => (
        <div key={tx.hash}>
          <p>Hash: {tx.hash}</p>
          <p>Status: {tx.status}</p>
          <p>Value: {tx.value}</p>
        </div>
      ))}
    </div>
  )
}
```

## Error Handling

### Comprehensive Error Management

```tsx
import { useState, useEffect } from 'react'

function ErrorHandler() {
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (error) {
      const timer = setTimeout(() => setError(null), 5000)
      return () => clearTimeout(timer)
    }
  }, [error])

  return (
    <>
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          <div className="flex items-center space-x-2">
            <span className="text-red-600">⚠️</span>
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      )}
    </>
  )
}
```

### Common Error Types

1. **Authentication Errors**
   - Invalid credentials
   - Network connectivity issues
   - Civic service unavailable

2. **Wallet Errors**
   - Connection failures
   - Insufficient balance
   - Transaction rejections

3. **Network Errors**
   - RPC endpoint issues
   - Chain switching failures
   - Gas estimation problems

## Security Features

### Implemented Security Measures

- **Reentrancy Protection** - All external functions protected
- **Input Validation** - Comprehensive parameter validation
- **Error Boundaries** - Graceful error handling
- **Secure Key Storage** - Civic-managed key storage
- **Network Validation** - Chain ID verification
- **Transaction Validation** - Gas and balance checks

### Best Practices

1. **Environment Variables**
   - Never commit sensitive data
   - Use proper validation
   - Secure key management

2. **User Experience**
   - Clear error messages
   - Loading states
   - Confirmation dialogs

3. **Network Security**
   - HTTPS only
   - Secure RPC endpoints
   - Chain validation

## Testing

### Component Testing

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { SimpleWalletConnection } from '@/components/web3/SimpleWalletConnection'

test('renders wallet connection', () => {
  render(<SimpleWalletConnection />)
  expect(screen.getByText('Authentication')).toBeInTheDocument()
})
```

### Hook Testing

```tsx
import { renderHook } from '@testing-library/react'
import { useWalletTransactions } from '@/hooks/useWalletTransactions'

test('useWalletTransactions returns expected values', () => {
  const { result } = renderHook(() => useWalletTransactions())
  
  expect(result.current.transactions).toEqual([])
  expect(result.current.isLoading).toBe(false)
  expect(result.current.error).toBeNull()
})
```

## Deployment

### Production Setup

1. **Environment Variables**
   ```env
   VITE_CIVIC_CLIENT_ID=your_production_client_id
   VITE_RPC_URL=https://mainnet.infura.io/v3/your_project_id
   ```

2. **Civic Dashboard**
   - Update redirect URIs
   - Configure production chains
   - Enable embedded wallet

3. **Build and Deploy**
   ```bash
   npm run build
   npm run preview
   ```

### Environment-Specific Configuration

```tsx
// frontend/src/config/environment.ts
export const config = {
  civic: {
    clientId: process.env.VITE_CIVIC_CLIENT_ID,
    redirectUri: process.env.VITE_CIVIC_REDIRECT_URI,
  },
  rpc: {
    mainnet: process.env.VITE_MAINNET_RPC_URL,
    sepolia: process.env.VITE_SEPOLIA_RPC_URL,
    polygon: process.env.VITE_POLYGON_RPC_URL,
    arbitrum: process.env.VITE_ARBITRUM_RPC_URL,
  },
}
```

## Troubleshooting

### Common Issues

1. **Civic Authentication Fails**
   - Check client ID configuration
   - Verify redirect URI settings
   - Ensure network connectivity

2. **Wallet Connection Issues**
   - Verify Civic embedded wallet setup
   - Check Wagmi configuration
   - Validate chain configuration

3. **Transaction Failures**
   - Check gas estimation
   - Verify balance sufficiency
   - Validate transaction parameters

### Debug Commands

```bash
# Check environment variables
echo $VITE_CIVIC_CLIENT_ID

# Test Civic connection
curl -X GET "https://auth.civic.com/api/v1/health"

# Verify Wagmi setup
npm run dev
```

## Performance Optimization

### Implemented Optimizations

- **Lazy Loading** - Components loaded on demand
- **Memoization** - React.memo for expensive components
- **Efficient Queries** - Optimized data fetching
- **Bundle Splitting** - Code splitting for better performance
- **Caching** - React Query for data caching

### Monitoring

```tsx
import { useAccount, useBalance } from 'wagmi'

function PerformanceMonitor() {
  const { address } = useAccount()
  const { data: balance } = useBalance({ address })

  useEffect(() => {
    // Monitor performance metrics
    console.log('Wallet connection performance:', {
      address,
      balance: balance?.formatted,
      timestamp: Date.now(),
    })
  }, [address, balance])

  return null
}
```

## Future Enhancements

### Planned Features

1. **Multi-wallet Support**
   - Multiple embedded wallets
   - Wallet switching
   - Portfolio management

2. **Advanced Analytics**
   - Transaction analytics
   - Gas optimization
   - Portfolio tracking

3. **Enhanced Security**
   - Hardware wallet support
   - Multi-factor authentication
   - Advanced key management

4. **Mobile Optimization**
   - Responsive design
   - Touch-friendly interface
   - Mobile-specific features

## Support

For issues and questions:
- Check the troubleshooting section
- Review Civic documentation
- Consult Wagmi documentation
- Create an issue in the repository

## License

MIT License - See LICENSE file for details. 
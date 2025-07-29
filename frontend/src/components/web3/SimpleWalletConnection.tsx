import React, { useState, useEffect } from 'react'
import { useAccount, useBalance, useConnect, useDisconnect, useSwitchChain, useChainId } from 'wagmi'
import { useUser } from '@civic/auth-web3/react'
import { UserButton } from '@civic/auth-web3/react'
import { mainnet, sepolia, polygon, arbitrum } from 'wagmi/chains'
import { cn } from '@/utils/cn'

// Types
interface SimpleWalletConnectionProps {
  className?: string
}

// Component
export const SimpleWalletConnection: React.FC<SimpleWalletConnectionProps> = ({ className }) => {
  // Civic hooks
  const userContext = useUser()
  const { authStatus, user } = userContext

  // Wagmi hooks
  const { address, isConnected, isConnecting } = useAccount()
  const { data: balance, isLoading: balanceLoading } = useBalance({
    address,
  })
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()
  const { switchChain } = useSwitchChain()
  const chainId = useChainId()

  // Local state
  const [error, setError] = useState<string | null>(null)

  // Error handling
  useEffect(() => {
    if (error) {
      const timer = setTimeout(() => setError(null), 5000)
      return () => clearTimeout(timer)
    }
  }, [error])

  // Handle wallet connection
  const handleConnectWallet = async () => {
    setError(null)

    try {
      const civicConnector = connectors.find(connector => connector.id === 'civic')
      if (civicConnector) {
        await connect({ connector: civicConnector })
      } else {
        setError('Civic wallet connector not found')
      }
    } catch (err) {
      setError('Failed to connect wallet. Please try again.')
      console.error('Wallet connection error:', err)
    }
  }

  // Handle network switching
  const handleSwitchNetwork = async (targetChainId: number) => {
    setError(null)

    try {
      await switchChain({ chainId: targetChainId })
    } catch (err) {
      setError('Failed to switch network. Please try again.')
      console.error('Network switch error:', err)
    }
  }

  // Get chain name
  const getChainName = (id: number) => {
    switch (id) {
      case mainnet.id: return 'Ethereum'
      case sepolia.id: return 'Sepolia'
      case polygon.id: return 'Polygon'
      case arbitrum.id: return 'Arbitrum'
      default: return 'Unknown'
    }
  }

  // Get chain icon
  const getChainIcon = (id: number) => {
    switch (id) {
      case mainnet.id: return '🔵'
      case sepolia.id: return '🟣'
      case polygon.id: return '🟣'
      case arbitrum.id: return '🔵'
      default: return '❓'
    }
  }

  // Format balance
  const formatBalance = (value: bigint, decimals: number, symbol: string) => {
    const formatted = Number(value) / Math.pow(10, decimals)
    return `${formatted.toFixed(4)} ${symbol}`
  }

  return (
    <div className={cn('space-y-4', className)}>
      {/* Error Display */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          <div className="flex items-center space-x-2">
            <span className="text-red-600">⚠️</span>
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      )}

      {/* Authentication Section */}
      <div className="bg-white border border-gray-200 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">Authentication</h3>
          <UserButton 
            className="civic-user-button"
            style={{ minWidth: "20rem" }}
          />
        </div>

        {/* Auth Status */}
        <div className="mt-3">
          <div className="flex items-center space-x-2">
            <span className={`inline-block w-2 h-2 rounded-full ${
              authStatus === 'authenticated' ? 'bg-green-500' : 
              authStatus === 'authenticating' ? 'bg-yellow-500' : 'bg-red-500'
            }`}></span>
            <span className="text-sm text-gray-600">
              {authStatus === 'authenticated' ? 'Authenticated' :
               authStatus === 'authenticating' ? 'Authenticating...' : 'Not authenticated'}
            </span>
          </div>
        </div>
      </div>

      {/* Wallet Section */}
      {user && (
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Wallet</h3>

          {/* Connection Status */}
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-2">
              <span className={`inline-block w-2 h-2 rounded-full ${
                isConnected ? 'bg-green-500' : 'bg-red-500'
              }`}></span>
              <span className="text-sm text-gray-600">
                {isConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>

            {!isConnected && (
              <button
                onClick={handleConnectWallet}
                disabled={isConnecting}
                className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isConnecting ? 'Connecting...' : 'Connect Wallet'}
              </button>
            )}

            {isConnected && (
              <button
                onClick={() => disconnect()}
                className="bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-red-700"
              >
                Disconnect
              </button>
            )}
          </div>

          {/* Wallet Address */}
          {isConnected && address && (
            <div className="bg-gray-50 p-3 rounded-lg mb-4">
              <p className="text-xs text-gray-500 mb-1">Wallet Address</p>
              <p className="text-sm font-mono text-gray-900 break-all">
                {address}
              </p>
            </div>
          )}

          {/* Balance Display */}
          {isConnected && address && (
            <div className="bg-gray-50 p-3 rounded-lg mb-4">
              <p className="text-xs text-gray-500 mb-1">Balance</p>
              {balanceLoading ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-600"></div>
                  <span className="text-sm text-gray-600">Loading...</span>
                </div>
              ) : balance ? (
                <p className="text-lg font-semibold text-gray-900">
                  {formatBalance(balance.value, balance.decimals, balance.symbol)}
                </p>
              ) : (
                <p className="text-sm text-gray-600">No balance data</p>
              )}
            </div>
          )}

          {/* Network Selection */}
          {isConnected && (
            <div className="bg-gray-50 p-3 rounded-lg">
              <p className="text-xs text-gray-500 mb-2">Network</p>
              <div className="flex flex-wrap gap-2">
                {[mainnet, sepolia, polygon, arbitrum].map((chain) => (
                  <button
                    key={chain.id}
                    onClick={() => handleSwitchNetwork(chain.id)}
                    className={cn(
                      'px-3 py-1 rounded-lg text-xs font-medium transition-colors',
                      chainId === chain.id
                        ? 'bg-blue-600 text-white'
                        : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
                    )}
                  >
                    <span className="mr-1">{getChainIcon(chain.id)}</span>
                    {getChainName(chain.id)}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Network Information */}
      {isConnected && (
        <div className="bg-white border border-gray-200 rounded-lg p-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Network Information</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-gray-50 p-3 rounded-lg">
              <p className="text-xs text-gray-500 mb-1">Current Network</p>
              <p className="text-sm font-semibold text-gray-900">
                {getChainIcon(chainId)} {getChainName(chainId)}
              </p>
            </div>
            <div className="bg-gray-50 p-3 rounded-lg">
              <p className="text-xs text-gray-500 mb-1">Chain ID</p>
              <p className="text-sm font-mono text-gray-900">{chainId}</p>
            </div>
          </div>
        </div>
      )}
    </div>
  )
} 
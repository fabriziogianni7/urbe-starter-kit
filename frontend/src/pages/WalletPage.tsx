import React from 'react'
import { SimpleWalletConnection } from '@/components/web3/SimpleWalletConnection'
import { TransactionHistory } from '@/components/web3/TransactionHistory'
import { useAccount } from 'wagmi'

export const WalletPage: React.FC = () => {
  const { isConnected } = useAccount()

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Wallet Management</h1>
          <p className="text-gray-600">
            Connect your wallet, manage your balance, and view transaction history
          </p>
        </div>

        {/* Wallet Connection */}
        <div className="mb-8">
          <SimpleWalletConnection />
        </div>

        {/* Transaction History - Only show when connected */}
        {isConnected && (
          <div className="mb-8">
            <TransactionHistory />
          </div>
        )}

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Civic Authentication */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-blue-600 text-lg">🔐</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Civic Authentication</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Secure Web3 authentication with SSO options including Google, Apple, X, Facebook, Discord, and GitHub.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Single Sign-On (SSO) integration</li>
              <li>• Email authentication</li>
              <li>• Embedded wallet creation</li>
              <li>• Multi-chain support</li>
            </ul>
          </div>

          {/* Embedded Wallet */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-green-600 text-lg">💼</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Embedded Wallet</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Create and manage wallets directly in your app with full Web3 capabilities.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Automatic wallet creation</li>
              <li>• Secure key management</li>
              <li>• Multi-network support</li>
              <li>• Seamless integration</li>
            </ul>
          </div>

          {/* Network Management */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-purple-600 text-lg">🌐</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Network Management</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Switch between different blockchain networks with ease.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Ethereum Mainnet</li>
              <li>• Sepolia Testnet</li>
              <li>• Polygon Network</li>
              <li>• Arbitrum Network</li>
            </ul>
          </div>

          {/* Balance Tracking */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-yellow-600 text-lg">💰</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Balance Tracking</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Real-time balance monitoring across all supported networks.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Real-time updates</li>
              <li>• Multi-token support</li>
              <li>• Network-specific balances</li>
              <li>• Historical tracking</li>
            </ul>
          </div>

          {/* Transaction History */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-red-600 text-lg">📊</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Transaction History</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Complete transaction history with detailed information and status tracking.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Detailed transaction info</li>
              <li>• Status tracking</li>
              <li>• Gas usage analytics</li>
              <li>• Block explorer links</li>
            </ul>
          </div>

          {/* Security Features */}
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <div className="flex items-center mb-4">
              <div className="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center mr-3">
                <span className="text-indigo-600 text-lg">🛡️</span>
              </div>
              <h3 className="text-lg font-semibold text-gray-900">Security Features</h3>
            </div>
            <p className="text-gray-600 text-sm mb-4">
              Enterprise-grade security with comprehensive error handling and validation.
            </p>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>• Reentrancy protection</li>
              <li>• Input validation</li>
              <li>• Error handling</li>
              <li>• Secure key storage</li>
            </ul>
          </div>
        </div>

        {/* Getting Started */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mt-8">
          <h3 className="text-lg font-semibold text-blue-900 mb-3">Getting Started</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <h4 className="font-medium text-blue-800 mb-2">1. Authentication</h4>
              <p className="text-blue-700">
                Use the Civic UserButton to sign in with your preferred method (SSO or email).
              </p>
            </div>
            <div>
              <h4 className="font-medium text-blue-800 mb-2">2. Create Wallet</h4>
              <p className="text-blue-700">
                After authentication, create an embedded wallet to start using Web3 features.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-blue-800 mb-2">3. Connect Wallet</h4>
              <p className="text-blue-700">
                Connect your wallet to Wagmi for seamless Web3 interactions.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-blue-800 mb-2">4. Explore Networks</h4>
              <p className="text-blue-700">
                Switch between different networks and view your balances and transactions.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
} 
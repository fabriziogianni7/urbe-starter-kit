import React from 'react'
import { Wallet, User, Shield, Activity, Settings } from 'lucide-react'
import { useUser } from '../components/civic/CivicProvider'
import { useWeb3 } from '../components/web3/Web3Provider'

export const DashboardPage: React.FC = () => {
  const { user, authStatus } = useUser()
  const { isConnected, address, balance, chainId } = useWeb3()

  // Check if user is authenticated based on authStatus
  const isAuthenticated = authStatus === 'authenticated'

  if (!isAuthenticated) {
    return (
      <div className="text-center py-12">
        <h1 className="text-2xl font-bold mb-4">Authentication Required</h1>
        <p className="text-gray-600">Please log in to access the dashboard.</p>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <div className="flex items-center space-x-2">
          <User className="h-5 w-5 text-gray-400" />
          <span className="text-sm text-gray-600">Welcome, {user?.name}</span>
        </div>
      </div>

      {/* Status Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="card">
          <div className="flex items-center space-x-3">
            <div className={`w-3 h-3 rounded-full ${isAuthenticated ? 'bg-green-500' : 'bg-red-500'}`} />
            <div>
              <p className="text-sm text-gray-500">Civic Auth</p>
              <p className="font-semibold">{isAuthenticated ? 'Connected' : 'Disconnected'}</p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <div className={`w-3 h-3 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`} />
            <div>
              <p className="text-sm text-gray-500">Wallet</p>
              <p className="font-semibold">{isConnected ? 'Connected' : 'Disconnected'}</p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <Wallet className="h-5 w-5 text-blue-600" />
            <div>
              <p className="text-sm text-gray-500">Network</p>
              <p className="font-semibold">Chain ID: {chainId || 'Unknown'}</p>
            </div>
          </div>
        </div>

        <div className="card">
          <div className="flex items-center space-x-3">
            <Shield className="h-5 w-5 text-green-600" />
            <div>
              <p className="text-sm text-gray-500">Balance</p>
              <p className="font-semibold">
                {balance ? `${parseFloat(balance.formatted).toFixed(4)} ${balance.symbol}` : 'N/A'}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* User Information */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">User Information</h2>
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">User ID</label>
              <p className="text-gray-900">{user?.id || 'N/A'}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
              <p className="text-gray-900">{user?.name || 'N/A'}</p>
            </div>
          </div>
          {user?.email && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <p className="text-gray-900">{user.email}</p>
            </div>
          )}
          {address && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Wallet Address</label>
              <p className="text-gray-900 font-mono text-sm">{address}</p>
            </div>
          )}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="flex items-center space-x-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Activity className="h-5 w-5 text-blue-600" />
            <span className="font-medium">View Transactions</span>
          </button>
          <button className="flex items-center space-x-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Settings className="h-5 w-5 text-gray-600" />
            <span className="font-medium">Settings</span>
          </button>
          <button className="flex items-center space-x-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
            <Wallet className="h-5 w-5 text-green-600" />
            <span className="font-medium">Manage Wallet</span>
          </button>
        </div>
      </div>
    </div>
  )
} 
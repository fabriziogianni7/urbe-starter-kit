import React from 'react'
import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { Wallet, LogOut } from 'lucide-react'
import { cn } from '../../utils/cn'

export const ConnectButton: React.FC = () => {
  const { address, isConnected } = useAccount()
  const { connect, connectors, isConnecting } = useConnect()
  const { disconnect } = useDisconnect()

  const handleConnect = () => {
    if (connectors[0]) {
      connect({ connector: connectors[0] })
    }
  }

  const handleDisconnect = () => {
    disconnect()
  }

  if (isConnected) {
    return (
      <div className="flex items-center space-x-2">
        <div className="flex items-center space-x-2 px-3 py-2 bg-green-50 text-green-700 rounded-md">
          <Wallet className="h-4 w-4" />
          <span className="text-sm font-medium">
            {address?.slice(0, 6)}...{address?.slice(-4)}
          </span>
        </div>
        <button
          onClick={handleDisconnect}
          className="flex items-center space-x-1 px-3 py-2 text-sm text-gray-500 hover:text-gray-700 transition-colors"
        >
          <LogOut className="h-4 w-4" />
          <span>Disconnect</span>
        </button>
      </div>
    )
  }

  return (
    <button
      onClick={handleConnect}
      disabled={isConnecting}
      className={cn(
        'flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-md font-medium transition-colors',
        'hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2',
        'disabled:opacity-50 disabled:cursor-not-allowed'
      )}
    >
      <Wallet className="h-4 w-4" />
      <span>{isConnecting ? 'Connecting...' : 'Connect Wallet'}</span>
    </button>
  )
} 
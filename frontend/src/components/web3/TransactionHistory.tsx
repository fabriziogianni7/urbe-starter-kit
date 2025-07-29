import React from 'react'
import { useWalletTransactions } from '@/hooks/useWalletTransactions'
import { cn } from '@/utils/cn'

interface TransactionHistoryProps {
  className?: string
}

export const TransactionHistory: React.FC<TransactionHistoryProps> = ({ className }) => {
  const { transactions, isLoading, error, fetchTransactions } = useWalletTransactions()

  // Format transaction value
  const formatValue = (value: string) => {
    const numValue = Number(value)
    if (numValue === 0) return '0 ETH'
    return `${(numValue / 1e18).toFixed(6)} ETH`
  }

  // Format timestamp
  const formatTimestamp = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleString()
  }

  // Get status color
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'bg-green-100 text-green-800'
      case 'pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'failed':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  // Get status icon
  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return '✅'
      case 'pending':
        return '⏳'
      case 'failed':
        return '❌'
      default:
        return '❓'
    }
  }

  return (
    <div className={cn('bg-white border border-gray-200 rounded-lg p-4', className)}>
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">Transaction History</h3>
        <button
          onClick={fetchTransactions}
          disabled={isLoading}
          className="text-sm text-blue-600 hover:text-blue-700 disabled:opacity-50"
        >
          {isLoading ? 'Refreshing...' : 'Refresh'}
        </button>
      </div>

      {/* Error Display */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
          <div className="flex items-center space-x-2">
            <span className="text-red-600">⚠️</span>
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      )}

      {/* Loading State */}
      {isLoading && (
        <div className="flex items-center justify-center py-8">
          <div className="flex flex-col items-center space-y-2">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <p className="text-sm text-gray-600">Loading transactions...</p>
          </div>
        </div>
      )}

      {/* Transaction List */}
      {!isLoading && (
        <div className="space-y-3">
          {transactions.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-gray-500">No transactions found</p>
              <p className="text-sm text-gray-400 mt-1">
                Your recent transactions will appear here
              </p>
            </div>
          ) : (
            transactions.map((tx) => (
              <div
                key={tx.hash}
                className="border border-gray-200 rounded-lg p-3 hover:bg-gray-50 transition-colors"
              >
                {/* Transaction Header */}
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center space-x-2">
                    <span className="text-lg">{getStatusIcon(tx.status)}</span>
                    <span className={cn(
                      'px-2 py-1 rounded text-xs font-medium',
                      getStatusColor(tx.status)
                    )}>
                      {tx.status}
                    </span>
                  </div>
                  <span className="text-xs text-gray-500">
                    {formatTimestamp(tx.timestamp)}
                  </span>
                </div>

                {/* Transaction Hash */}
                <div className="mb-2">
                  <p className="text-xs text-gray-500 mb-1">Transaction Hash</p>
                  <p className="text-sm font-mono text-gray-900 break-all">
                    {tx.hash}
                  </p>
                </div>

                {/* Transaction Details */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                  <div>
                    <p className="text-gray-500 mb-1">From</p>
                    <p className="font-mono text-gray-900 break-all">
                      {tx.from}
                    </p>
                  </div>
                  <div>
                    <p className="text-gray-500 mb-1">To</p>
                    <p className="font-mono text-gray-900 break-all">
                      {tx.to}
                    </p>
                  </div>
                </div>

                {/* Transaction Value */}
                <div className="mt-3 pt-3 border-t border-gray-200">
                  <div className="flex items-center justify-between">
                    <span className="text-gray-500 text-xs">Value</span>
                    <span className="font-semibold text-gray-900">
                      {formatValue(tx.value)}
                    </span>
                  </div>
                </div>

                {/* Additional Details */}
                {(tx.blockNumber || tx.gasUsed || tx.gasPrice) && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-xs">
                      {tx.blockNumber && (
                        <div>
                          <span className="text-gray-500">Block</span>
                          <p className="font-mono text-gray-900">{tx.blockNumber.toString()}</p>
                        </div>
                      )}
                      {tx.gasUsed && (
                        <div>
                          <span className="text-gray-500">Gas Used</span>
                          <p className="font-mono text-gray-900">{tx.gasUsed?.toString() || '0'}</p>
                        </div>
                      )}
                      {tx.gasPrice && (
                        <div>
                          <span className="text-gray-500">Gas Price</span>
                          <p className="font-mono text-gray-900">
                            {tx.gasPrice ? (Number(tx.gasPrice) / 1e9).toFixed(2) : '0'} Gwei
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      )}
    </div>
  )
} 
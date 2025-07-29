import { useState, useEffect } from 'react'
import { useAccount, usePublicClient } from 'wagmi'

export interface Transaction {
  hash: string
  from: string
  to: string
  value: string
  timestamp: number
  status: 'pending' | 'success' | 'failed'
  blockNumber?: number
  gasUsed?: bigint
  gasPrice?: bigint
}

export const useWalletTransactions = () => {
  const { address } = useAccount()
  const publicClient = usePublicClient()
  const [transactions, setTransactions] = useState<Transaction[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Fetch transaction history
  const fetchTransactions = async () => {
    if (!address || !publicClient) return

    setIsLoading(true)
    setError(null)

    try {
      // Get the latest block number
      const blockNumber = await publicClient.getBlockNumber()
      
      // Fetch recent transactions (last 10 blocks)
      const recentTransactions: Transaction[] = []
      
      for (let i = 0; i < 10; i++) {
        const block = await publicClient.getBlock({
          blockNumber: blockNumber - BigInt(i),
          includeTransactions: true,
        })

        if (block.transactions) {
          for (const tx of block.transactions) {
            if (typeof tx === 'object' && 'from' in tx && 'to' in tx) {
              if (tx.from?.toLowerCase() === address.toLowerCase() || 
                  tx.to?.toLowerCase() === address.toLowerCase()) {
                
                // Get transaction receipt
                const receipt = await publicClient.getTransactionReceipt({
                  hash: tx.hash,
                })

                recentTransactions.push({
                  hash: tx.hash,
                  from: tx.from || '',
                  to: tx.to || '',
                  value: tx.value?.toString() || '0',
                  timestamp: Number(block.timestamp),
                  status: receipt.status === 'success' ? 'success' : 'failed',
                  blockNumber: Number(block.number),
                  gasUsed: receipt.gasUsed,
                  gasPrice: tx.gasPrice,
                })
              }
            }
          }
        }
      }

      setTransactions(recentTransactions)
    } catch (err) {
      setError('Failed to fetch transaction history')
      console.error('Transaction fetch error:', err)
    } finally {
      setIsLoading(false)
    }
  }

  // Add a new transaction
  const addTransaction = (transaction: Omit<Transaction, 'timestamp'>) => {
    const newTransaction: Transaction = {
      ...transaction,
      timestamp: Date.now(),
    }
    
    setTransactions(prev => [newTransaction, ...prev])
  }

  // Update transaction status
  const updateTransactionStatus = (hash: string, status: Transaction['status']) => {
    setTransactions(prev => 
      prev.map(tx => 
        tx.hash === hash ? { ...tx, status } : tx
      )
    )
  }

  // Clear transactions
  const clearTransactions = () => {
    setTransactions([])
  }

  // Fetch transactions when address changes
  useEffect(() => {
    if (address) {
      fetchTransactions()
    } else {
      setTransactions([])
    }
  }, [address])

  return {
    transactions,
    isLoading,
    error,
    fetchTransactions,
    addTransaction,
    updateTransactionStatus,
    clearTransactions,
  }
} 
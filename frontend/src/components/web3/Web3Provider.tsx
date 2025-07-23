import React, { createContext, useContext, ReactNode } from 'react'
import { useAccount, useNetwork, useBalance } from 'wagmi'

// Web3 context interface
interface Web3ContextType {
  isConnected: boolean
  address: string | undefined
  chainId: number | undefined
  balance: any
  isLoading: boolean
  error: any
}

// Create context
const Web3Context = createContext<Web3ContextType | undefined>(undefined)

// Web3 provider props
interface Web3ProviderProps {
  children: ReactNode
}

// Web3 provider component
export const Web3Provider: React.FC<Web3ProviderProps> = ({ children }) => {
  const { address, isConnected, isConnecting } = useAccount()
  const { chain } = useNetwork()
  const { data: balance, isLoading: balanceLoading } = useBalance({
    address,
    watch: true,
  })

  const isLoading = isConnecting || balanceLoading
  const error = null // TODO: Implement error handling

  const value: Web3ContextType = {
    isConnected,
    address,
    chainId: chain?.id,
    balance,
    isLoading,
    error,
  }

  return (
    <Web3Context.Provider value={value}>
      {children}
    </Web3Context.Provider>
  )
}

// Custom hook to use Web3 context
export const useWeb3 = () => {
  const context = useContext(Web3Context)
  if (context === undefined) {
    throw new Error('useWeb3 must be used within a Web3Provider')
  }
  return context
} 
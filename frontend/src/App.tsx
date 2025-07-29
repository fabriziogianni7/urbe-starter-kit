import React from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider } from 'wagmi'
import { config } from './wagmi/config'
import { CivicProvider } from './components/web3/CivicProvider'
import { WalletPage } from './pages/WalletPage'
import './styles/globals.css'

// Create a client
const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiProvider config={config}>
        <CivicProvider>
          <div className="min-h-screen bg-gray-50">
            <WalletPage />
          </div>
        </CivicProvider>
      </WagmiProvider>
    </QueryClientProvider>
  )
}

export default App 
import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'react-hot-toast'
import { WagmiProvider } from 'wagmi'
import { config } from './wagmi/config'
import { CivicProvider } from './components/civic/CivicProvider'
import { Web3Provider } from './components/web3/Web3Provider'
import { Layout } from './components/layout/Layout'
import { HomePage } from './pages/HomePage'
import { DashboardPage } from './pages/DashboardPage'
import { ContractPage } from './pages/ContractPage'
import { AuthCallbackPage } from './pages/AuthCallbackPage'
import { ErrorBoundary } from './components/ErrorBoundary'
import './styles/globals.css'

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 3,
    },
  },
})

function App() {
  return (
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <WagmiProvider config={config}>
          <CivicProvider>
            <Web3Provider>
              <Router>
                <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
                  <Layout>
                    <Routes>
                      <Route path="/" element={<HomePage />} />
                      <Route path="/dashboard" element={<DashboardPage />} />
                      <Route path="/contract" element={<ContractPage />} />
                      <Route path="/auth/callback" element={<AuthCallbackPage />} />
                    </Routes>
                  </Layout>
                  <Toaster
                    position="top-right"
                    toastOptions={{
                      duration: 4000,
                      style: {
                        background: '#363636',
                        color: '#fff',
                      },
                    }}
                  />
                </div>
              </Router>
            </Web3Provider>
          </CivicProvider>
        </WagmiProvider>
      </QueryClientProvider>
    </ErrorBoundary>
  )
}

export default App 
import React from 'react'
import { CivicAuthProvider } from '@civic/auth-web3/react'
import { mainnet } from 'wagmi/chains'

interface CivicProviderProps {
  children: React.ReactNode
}

export const CivicProvider: React.FC<CivicProviderProps> = ({ children }) => {
  const clientId = process.env.VITE_CIVIC_CLIENT_ID

  if (!clientId) {
    console.warn('VITE_CIVIC_CLIENT_ID is not set. Civic authentication will not work.')
    return <>{children}</>
  }

  return (
    <CivicAuthProvider 
      clientId={clientId}
      initialChain={mainnet}
      onSignIn={(error) => {
        if (error) {
          console.error('Civic sign in error:', error)
        }
      }}
      onSignOut={() => {
        console.log('User signed out')
      }}
    >
      {children}
    </CivicAuthProvider>
  )
} 
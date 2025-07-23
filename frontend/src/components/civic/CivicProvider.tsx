import React, { ReactNode } from 'react'
import { CivicAuthProvider } from '@civic/auth-web3/react'

// Civic provider props
interface CivicProviderProps {
  children: ReactNode
}

// Civic provider component using real Civic SDK
export const CivicProvider: React.FC<CivicProviderProps> = ({ children }) => {
  return (
    <CivicAuthProvider 
      clientId={(import.meta as any).env?.VITE_CIVIC_CLIENT_ID || 'YOUR_CLIENT_ID'}
      // Optional configuration based on documentation
      onSignIn={(error?: Error) => {
        if (error) {
          console.error('Civic sign-in error:', error)
        } else {
          console.log('Civic sign-in successful')
        }
      }}
      onSignOut={() => {
        console.log('Civic sign-out successful')
      }}
    >
      {children}
    </CivicAuthProvider>
  )
}

// Export the useUser hook from Civic SDK
export { useUser } from '@civic/auth-web3/react' 
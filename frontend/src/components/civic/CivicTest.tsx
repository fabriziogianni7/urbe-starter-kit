import React from 'react'
import { useUser } from './CivicProvider'

export const CivicTest: React.FC = () => {
  const { user, authStatus, signIn, signOut, isLoading, error } = useUser()

  return (
    <div className="card">
      <h2 className="text-xl font-semibold mb-4">Civic Authentication Test</h2>
      
      <div className="space-y-4">
        {/* Status */}
        <div>
          <h3 className="font-medium text-gray-900 mb-2">Authentication Status</h3>
          <div className="flex items-center space-x-2">
            <div className={`w-3 h-3 rounded-full ${
              authStatus === 'authenticated' ? 'bg-green-500' : 
              authStatus === 'authenticating' ? 'bg-yellow-500' : 'bg-red-500'
            }`} />
            <span className="text-sm font-medium">
              {authStatus === 'authenticated' ? 'Authenticated' :
               authStatus === 'authenticating' ? 'Authenticating...' :
               authStatus === 'signing_out' ? 'Signing out...' :
               'Not authenticated'}
            </span>
          </div>
        </div>

        {/* User Info */}
        {user && (
          <div>
            <h3 className="font-medium text-gray-900 mb-2">User Information</h3>
            <div className="space-y-2 text-sm">
              <div>
                <span className="font-medium">ID:</span> {user.id}
              </div>
              <div>
                <span className="font-medium">Name:</span> {user.name || 'N/A'}
              </div>
              <div>
                <span className="font-medium">Email:</span> {user.email || 'N/A'}
              </div>
              {user.picture && (
                <div>
                  <span className="font-medium">Picture:</span> 
                  <img src={user.picture} alt="Profile" className="w-8 h-8 rounded-full ml-2" />
                </div>
              )}
            </div>
          </div>
        )}

        {/* Actions */}
        <div>
          <h3 className="font-medium text-gray-900 mb-2">Actions</h3>
          <div className="flex space-x-2">
            {!user ? (
              <button
                onClick={() => signIn()}
                disabled={isLoading}
                className="btn-primary disabled:opacity-50"
              >
                {isLoading ? 'Signing in...' : 'Sign In'}
              </button>
            ) : (
              <button
                onClick={() => signOut()}
                disabled={isLoading}
                className="btn-secondary disabled:opacity-50"
              >
                {isLoading ? 'Signing out...' : 'Sign Out'}
              </button>
            )}
          </div>
        </div>

        {/* Error Display */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-md p-3">
            <h3 className="font-medium text-red-900 mb-1">Error</h3>
            <p className="text-sm text-red-700">{error.message}</p>
          </div>
        )}
      </div>
    </div>
  )
} 
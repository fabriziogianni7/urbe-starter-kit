import React, { useEffect, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { CheckCircle, XCircle, Loader } from 'lucide-react'

export const AuthCallbackPage: React.FC = () => {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [message, setMessage] = useState('Processing authentication...')

  useEffect(() => {
    const handleAuthCallback = async () => {
      try {
        // Get URL parameters
        const code = searchParams.get('code')
        const error = searchParams.get('error')
        const state = searchParams.get('state')

        if (error) {
          setStatus('error')
          setMessage(`Authentication failed: ${error}`)
          setTimeout(() => navigate('/'), 3000)
          return
        }

        if (!code) {
          setStatus('error')
          setMessage('No authorization code received')
          setTimeout(() => navigate('/'), 3000)
          return
        }

        // TODO: Implement actual Civic token exchange
        // For now, simulate the process
        await new Promise(resolve => setTimeout(resolve, 2000))

        setStatus('success')
        setMessage('Authentication successful! Redirecting...')
        
        setTimeout(() => navigate('/dashboard'), 2000)
      } catch (error) {
        console.error('Auth callback error:', error)
        setStatus('error')
        setMessage('Authentication failed. Please try again.')
        setTimeout(() => navigate('/'), 3000)
      }
    }

    handleAuthCallback()
  }, [searchParams, navigate])

  const getIcon = () => {
    switch (status) {
      case 'loading':
        return <Loader className="h-12 w-12 text-blue-600 animate-spin" />
      case 'success':
        return <CheckCircle className="h-12 w-12 text-green-600" />
      case 'error':
        return <XCircle className="h-12 w-12 text-red-600" />
    }
  }

  const getBackgroundColor = () => {
    switch (status) {
      case 'loading':
        return 'bg-blue-50'
      case 'success':
        return 'bg-green-50'
      case 'error':
        return 'bg-red-50'
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <div className={`max-w-md w-full ${getBackgroundColor()} rounded-lg shadow-lg p-8`}>
        <div className="text-center">
          {getIcon()}
          <h1 className="mt-4 text-2xl font-bold text-gray-900">
            {status === 'loading' && 'Processing...'}
            {status === 'success' && 'Success!'}
            {status === 'error' && 'Error'}
          </h1>
          <p className="mt-2 text-gray-600">{message}</p>
          
          {status === 'loading' && (
            <div className="mt-6">
              <div className="flex justify-center space-x-2">
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce"></div>
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
} 
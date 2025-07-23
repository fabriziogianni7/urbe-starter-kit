import React from 'react'
import { Link } from 'react-router-dom'
import { Wallet, Shield, Zap, Users, BookOpen, Code, Edit3 } from 'lucide-react'
import { useUser } from '../components/civic/CivicProvider'
import { useWeb3 } from '../components/web3/Web3Provider'

export const HomePage: React.FC = () => {
  const { user, authStatus, signIn } = useUser()
  const { isConnected } = useWeb3()

  // Check if user is authenticated based on authStatus
  const isAuthenticated = authStatus === 'authenticated'

  const features = [
    {
      icon: Wallet,
      title: 'Web3 Authentication',
      description: 'Secure login with Civic, supporting multiple chains and wallet options.',
    },
    {
      icon: Shield,
      title: 'Smart Contracts',
      description: 'Deploy and interact with Solidity contracts using Foundry.',
    },
    {
      icon: Zap,
      title: 'Wagmi Integration',
      description: 'React hooks for seamless Ethereum interactions.',
    },
    {
      icon: Users,
      title: 'User Management',
      description: 'Complete user authentication and profile management.',
    },
    {
      icon: BookOpen,
      title: 'Learning Resources',
      description: 'Comprehensive documentation and tutorials.',
    },
    {
      icon: Code,
      title: 'TypeScript',
      description: 'Full type safety for better development experience.',
    },
  ]

  return (
    <div className="space-y-12">
      {/* Hero Section */}
      <section className="text-center py-12">
        <h1 className="text-4xl md:text-6xl font-bold text-gradient mb-6">
          Web3 Starter Kit
        </h1>
        <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
          A comprehensive starter kit for learning Web3 development with React, Wagmi, Foundry, and Civic authentication.
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          {!isAuthenticated ? (
            <button
              onClick={() => signIn()}
              className="btn-primary text-lg px-8 py-3"
            >
              Get Started with Civic
            </button>
          ) : (
            <Link to="/dashboard" className="btn-primary text-lg px-8 py-3">
              Go to Dashboard
            </Link>
          )}
          <Link to="/contract" className="btn-secondary text-lg px-8 py-3">
            Explore Contracts
          </Link>
        </div>
      </section>

      {/* Customization Notice */}
      <section className="card bg-blue-50 border-blue-200">
        <div className="flex items-start space-x-4">
          <div className="flex-shrink-0 p-2 bg-blue-100 rounded-lg">
            <Edit3 className="h-6 w-6 text-blue-600" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-blue-900 mb-2">Ready to Build Your Own App?</h2>
            <p className="text-blue-800 mb-4">
              This is a starter template. You can delete all the content on this homepage and replace it with your own application!
            </p>
            <div className="space-y-2 text-sm text-blue-700">
              <p>• Replace the hero section with your app's introduction</p>
              <p>• Update the features to match your application</p>
              <p>• Customize the styling and branding</p>
              <p>• Add your own pages and components</p>
              <p>• Work with Cursor AI to ask and build about Wagmi, Civic, and smart contracts</p>
            </div>
          </div>
        </div>
      </section>

      {/* Status Section */}
      <section className="card">
        <h2 className="text-2xl font-bold mb-6">Connection Status</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="flex items-center space-x-3 p-4 bg-gray-50 rounded-lg">
            <div className={`w-3 h-3 rounded-full ${isAuthenticated ? 'bg-green-500' : 'bg-red-500'}`} />
            <span className="font-medium">Civic Authentication</span>
            <span className="text-sm text-gray-500">
              {isAuthenticated ? 'Connected' : 'Not connected'}
            </span>
          </div>
          <div className="flex items-center space-x-3 p-4 bg-gray-50 rounded-lg">
            <div className={`w-3 h-3 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`} />
            <span className="font-medium">Wallet Connection</span>
            <span className="text-sm text-gray-500">
              {isConnected ? 'Connected' : 'Not connected'}
            </span>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section>
        <h2 className="text-3xl font-bold text-center mb-12">Features</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => {
            const Icon = feature.icon
            return (
              <div key={index} className="card hover:shadow-md transition-shadow">
                <div className="flex items-center space-x-3 mb-4">
                  <div className="p-2 bg-blue-100 rounded-lg">
                    <Icon className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="text-lg font-semibold">{feature.title}</h3>
                </div>
                <p className="text-gray-600">{feature.description}</p>
              </div>
            )
          })}
        </div>
      </section>

      {/* Quick Start Section */}
      <section className="card">
        <h2 className="text-2xl font-bold mb-6">Quick Start</h2>
        <div className="space-y-4">
          <div className="flex items-start space-x-4">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-sm font-bold text-blue-600">1</span>
            </div>
            <div>
              <h3 className="font-semibold">Install Dependencies</h3>
              <p className="text-gray-600">Run <code className="bg-gray-100 px-2 py-1 rounded">make install</code> to install all dependencies.</p>
            </div>
          </div>
          <div className="flex items-start space-x-4">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-sm font-bold text-blue-600">2</span>
            </div>
            <div>
              <h3 className="font-semibold">Configure Environment</h3>
              <p className="text-gray-600">Copy <code className="bg-gray-100 px-2 py-1 rounded">frontend/.env.example</code> to <code className="bg-gray-100 px-2 py-1 rounded">frontend/.env</code> and add your Civic client ID.</p>
            </div>
          </div>
          <div className="flex items-start space-x-4">
            <div className="flex-shrink-0 w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-sm font-bold text-blue-600">3</span>
            </div>
            <div>
              <h3 className="font-semibold">Start Development</h3>
              <p className="text-gray-600">Run <code className="bg-gray-100 px-2 py-1 rounded">make dev</code> to start the development server.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
} 
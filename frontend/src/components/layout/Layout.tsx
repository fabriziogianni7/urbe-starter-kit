import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Wallet, Home, Settings } from 'lucide-react'
import { useUser } from '../civic/CivicProvider'
import { useWeb3 } from '../web3/Web3Provider'
import { ConnectButton } from '../web3/ConnectButton'
import { UserButton } from '../civic/UserButton'
import { cn } from '../../utils/cn'

interface LayoutProps {
  children: React.ReactNode
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation()
  const { user } = useUser()
  const { isConnected } = useWeb3()

  const navigation = [
    { name: 'Home', href: '/', icon: Home },
    { name: 'Dashboard', href: '/dashboard', icon: Settings },
    { name: 'Contract', href: '/contract', icon: Wallet },
  ]

  const isActive = (href: string) => location.pathname === href

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center">
              <Link to="/" className="flex items-center space-x-2">
                <Wallet className="h-8 w-8 text-blue-600" />
                <span className="text-xl font-bold text-gray-900">
                  Web3 Starter Kit
                </span>
              </Link>
            </div>

            {/* Navigation */}
            <nav className="hidden md:flex space-x-8">
              {navigation.map((item) => {
                const Icon = item.icon
                return (
                  <Link
                    key={item.name}
                    to={item.href}
                    className={cn(
                      'flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                      isActive(item.href)
                        ? 'text-blue-600 bg-blue-50'
                        : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
                    )}
                  >
                    <Icon className="h-4 w-4" />
                    <span>{item.name}</span>
                  </Link>
                )
              })}
            </nav>

            {/* User menu */}
            <div className="flex items-center space-x-4">
              <ConnectButton />
              
              {/* Civic UserButton */}
              <UserButton 
                className="civic-user-button"
                dropdownButtonClassName="civic-dropdown-button"
              />
            </div>
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-500">
              © 2024 Web3 Starter Kit. Built for learning.
            </div>
            <div className="flex space-x-6">
              <a
                href="https://github.com/your-repo"
                className="text-sm text-gray-500 hover:text-gray-700"
              >
                GitHub
              </a>
              <a
                href="https://docs.example.com"
                className="text-sm text-gray-500 hover:text-gray-700"
              >
                Docs
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
} 
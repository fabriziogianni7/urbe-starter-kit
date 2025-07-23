import React, { useState } from 'react'
import { useContractRead, useContractWrite } from 'wagmi'
import { Wallet, Send, Database, RefreshCw } from 'lucide-react'
import { useWeb3 } from '../components/web3/Web3Provider'

// Example contract ABI (SimpleStorage)
const contractABI = [
  {
    inputs: [],
    name: "retrieve",
    outputs: [{ type: "uint256", name: "" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ type: "uint256", name: "num" }],
    name: "store",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const

export const ContractPage: React.FC = () => {
  const { isConnected } = useWeb3()
  const [value, setValue] = useState('')
  
  // Example contract address (replace with your deployed contract)
  const contractAddress = (import.meta as any).env?.VITE_CONTRACT_ADDRESS || '0x0000000000000000000000000000000000000000'

  // Read contract value
  const { data: storedValue, isLoading: isReading, refetch } = useContractRead({
    address: contractAddress as `0x${string}`,
    abi: contractABI,
    functionName: 'retrieve',
  })

  // Write to contract
  const { writeContract, isPending: isWriting } = useContractWrite()

  const handleStore = () => {
    if (value && contractAddress !== '0x0000000000000000000000000000000000000000') {
      writeContract({
        address: contractAddress as `0x${string}`,
        abi: contractABI,
        functionName: 'store',
        args: [BigInt(value)],
      })
    }
  }

  if (!isConnected) {
    return (
      <div className="text-center py-12">
        <Wallet className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <h1 className="text-2xl font-bold mb-4">Wallet Not Connected</h1>
        <p className="text-gray-600">Please connect your wallet to interact with smart contracts.</p>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold">Smart Contract Interaction</h1>
        <div className="flex items-center space-x-2">
          <Database className="h-5 w-5 text-blue-600" />
          <span className="text-sm text-gray-600">Contract: {contractAddress.slice(0, 6)}...{contractAddress.slice(-4)}</span>
        </div>
      </div>

      {/* Contract Status */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Contract Status</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Stored Value</label>
            <div className="flex items-center space-x-3">
              <div className="flex-1 p-3 bg-gray-50 rounded-md">
                {isReading ? (
                  <div className="flex items-center space-x-2">
                    <RefreshCw className="h-4 w-4 animate-spin" />
                    <span className="text-gray-500">Loading...</span>
                  </div>
                ) : (
                  <span className="font-mono text-lg">{storedValue?.toString() || '0'}</span>
                )}
              </div>
              <button
                onClick={() => refetch()}
                disabled={isReading}
                className="px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                <RefreshCw className="h-4 w-4" />
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Contract Address</label>
            <div className="p-3 bg-gray-50 rounded-md">
              <span className="font-mono text-sm break-all">{contractAddress}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Contract Interaction */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Store New Value</h2>
        <div className="space-y-4">
          <div>
            <label htmlFor="value" className="block text-sm font-medium text-gray-700 mb-2">
              New Value
            </label>
            <input
              id="value"
              type="number"
              value={value}
              onChange={(e) => setValue(e.target.value)}
              placeholder="Enter a number"
              className="input"
            />
          </div>
          <button
            onClick={handleStore}
            disabled={!value || isWriting}
            className="btn-primary flex items-center space-x-2"
          >
            <Send className="h-4 w-4" />
            <span>{isWriting ? 'Processing...' : 'Store Value'}</span>
          </button>
        </div>
      </div>

      {/* Transaction Status */}
      {isWriting && (
        <div className="card bg-blue-50 border-blue-200">
          <div className="flex items-center space-x-3">
            <RefreshCw className="h-5 w-5 text-blue-600 animate-spin" />
            <div>
              <h3 className="font-semibold text-blue-900">Transaction in Progress</h3>
              <p className="text-sm text-blue-700">
                Waiting for wallet confirmation...
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Contract Information */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Contract Information</h2>
        <div className="space-y-4">
          <div>
            <h3 className="font-medium text-gray-900 mb-2">SimpleStorage Contract</h3>
            <p className="text-gray-600 text-sm">
              This is a simple storage contract that allows you to store and retrieve a single uint256 value.
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded-md">
            <h4 className="font-medium text-gray-900 mb-2">Functions</h4>
            <div className="space-y-2 text-sm">
              <div>
                <code className="bg-white px-2 py-1 rounded">store(uint256 num)</code>
                <span className="text-gray-600 ml-2">- Store a new value</span>
              </div>
              <div>
                <code className="bg-white px-2 py-1 rounded">retrieve()</code>
                <span className="text-gray-600 ml-2">- Get the stored value</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
} 
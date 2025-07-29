import { http, createConfig } from 'wagmi'
import { mainnet, sepolia, polygon, arbitrum } from 'wagmi/chains'
import { walletConnect, coinbaseWallet } from 'wagmi/connectors'
import { embeddedWallet } from '@civic/auth-web3/wagmi'

// Get environment variables
const projectId = process.env.VITE_WALLET_CONNECT_PROJECT_ID || 'your-project-id'

export const config = createConfig({
  chains: [mainnet, sepolia, polygon, arbitrum],
  connectors: [
    embeddedWallet(), // Civic embedded wallet (first priority)
    walletConnect({ projectId }),
    coinbaseWallet({ appName: 'Web3 Starter Kit' }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(process.env.VITE_RPC_URL || 'https://sepolia.infura.io/v3/your-project-id'),
    [polygon.id]: http(),
    [arbitrum.id]: http(),
  },
  ssr: true,
}) 
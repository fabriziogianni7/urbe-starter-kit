import { http, createConfig } from 'wagmi'
import { mainnet, sepolia, polygon, arbitrum } from 'wagmi/chains'
import { injected, walletConnect, coinbaseWallet } from 'wagmi/connectors'

// Get environment variables
const projectId = import.meta.env.VITE_WALLET_CONNECT_PROJECT_ID || 'your-project-id'

export const config = createConfig({
  chains: [mainnet, sepolia, polygon, arbitrum],
  connectors: [
    injected(),
    walletConnect({ projectId }),
    coinbaseWallet({ appName: 'Web3 Starter Kit' }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(import.meta.env.VITE_RPC_URL || 'https://sepolia.infura.io/v3/your-project-id'),
    [polygon.id]: http(),
    [arbitrum.id]: http(),
  },
  ssr: true,
}) 
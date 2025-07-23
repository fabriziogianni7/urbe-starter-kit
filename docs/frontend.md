# Frontend Development Guide

This guide covers frontend development using React, Wagmi, TypeScript, and Tailwind CSS.

## Overview

The frontend is built with:
- **React 18** - Modern React with hooks and concurrent features
- **TypeScript** - Type safety and better developer experience
- **Wagmi** - React hooks for Ethereum
- **Vite** - Fast build tool and development server
- **Tailwind CSS** - Utility-first CSS framework
- **Civic** - Web3 authentication

## Project Structure

```
frontend/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── ui/            # Basic UI components
│   │   ├── web3/          # Web3-specific components
│   │   └── civic/         # Civic authentication components
│   ├── hooks/              # Custom React hooks
│   ├── pages/              # Page components
│   ├── utils/              # Utility functions
│   ├── types/              # TypeScript type definitions
│   ├── constants/          # Application constants
│   ├── wagmi/              # Wagmi configuration
│   └── styles/             # Global styles
├── public/                 # Static assets
├── package.json            # Dependencies and scripts
└── vite.config.ts         # Vite configuration
```

## Getting Started

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Environment Setup

Copy `env.example` to `.env` and configure:

```env
VITE_CIVIC_CLIENT_ID=your_civic_client_id
VITE_RPC_URL=https://sepolia.infura.io/v3/your_project_id
VITE_CONTRACT_ADDRESS=your_deployed_contract_address
```

### 3. Start Development Server

```bash
npm run dev
```

## React Components

### Component Structure

```typescript
import React from 'react';
import { cn } from '@/utils/cn';

interface ComponentProps {
  title: string;
  children: React.ReactNode;
  className?: string;
}

export const Component: React.FC<ComponentProps> = ({ 
  title, 
  children, 
  className 
}) => {
  return (
    <div className={cn('card', className)}>
      <h2 className="text-xl font-semibold mb-4">{title}</h2>
      {children}
    </div>
  );
};
```

### Custom Hooks

```typescript
import { useState, useEffect } from 'react';
import { useAccount, useBalance } from 'wagmi';

export const useWalletInfo = () => {
  const { address, isConnected } = useAccount();
  const { data: balance, isLoading } = useBalance({
    address,
    watch: true,
  });

  return {
    address,
    isConnected,
    balance,
    isLoading,
  };
};
```

## Wagmi Integration

### Configuration

```typescript
// src/wagmi/config.ts
import { http, createConfig } from 'wagmi';
import { mainnet, sepolia } from 'wagmi/chains';
import { injected, walletConnect } from 'wagmi/connectors';

export const config = createConfig({
  chains: [mainnet, sepolia],
  connectors: [
    injected(),
    walletConnect({ projectId: 'your_project_id' }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(process.env.VITE_RPC_URL),
  },
});
```

### Using Wagmi Hooks

```typescript
import { useAccount, useContractRead, useContractWrite } from 'wagmi';

function ContractInteraction() {
  const { address, isConnected } = useAccount();
  
  const { data: value, isLoading } = useContractRead({
    address: contractAddress,
    abi: contractABI,
    functionName: 'retrieve',
  });

  const { write, isLoading: isWriting } = useContractWrite({
    address: contractAddress,
    abi: contractABI,
    functionName: 'store',
  });

  const handleStore = () => {
    if (write) {
      write({ args: [42] });
    }
  };

  return (
    <div>
      <p>Stored Value: {value?.toString()}</p>
      <button onClick={handleStore} disabled={isWriting}>
        Store Value
      </button>
    </div>
  );
}
```

## TypeScript Best Practices

### Type Definitions

```typescript
// src/types/index.ts
export interface User {
  id: string;
  name: string;
  email: string;
  walletAddress?: string;
}

export interface ContractConfig {
  address: string;
  abi: any[];
  chainId: number;
}

export type NetworkId = 1 | 11155111 | 137 | 42161;
```

### Generic Components

```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  className?: string;
}

export function List<T>({ items, renderItem, className }: ListProps<T>) {
  return (
    <div className={cn('space-y-2', className)}>
      {items.map((item, index) => renderItem(item, index))}
    </div>
  );
}
```

## State Management

### React Context

```typescript
// src/contexts/AppContext.tsx
import React, { createContext, useContext, useState } from 'react';

interface AppContextType {
  theme: 'light' | 'dark';
  setTheme: (theme: 'light' | 'dark') => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ 
  children 
}) => {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  return (
    <AppContext.Provider value={{ theme, setTheme }}>
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within AppProvider');
  }
  return context;
};
```

### Zustand Store

```typescript
// src/stores/appStore.ts
import { create } from 'zustand';

interface AppState {
  user: User | null;
  setUser: (user: User | null) => void;
  notifications: Notification[];
  addNotification: (notification: Notification) => void;
}

export const useAppStore = create<AppState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  notifications: [],
  addNotification: (notification) => 
    set((state) => ({ 
      notifications: [...state.notifications, notification] 
    })),
}));
```

## Styling with Tailwind CSS

### Custom Components

```typescript
// src/components/ui/Button.tsx
import { cn } from '@/utils/cn';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
}

export const Button: React.FC<ButtonProps> = ({ 
  variant = 'primary', 
  size = 'md', 
  className, 
  children, 
  ...props 
}) => {
  const baseClasses = 'font-medium rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-200 text-gray-700 hover:bg-gray-300 focus:ring-gray-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
  };
  
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-sm',
    lg: 'px-6 py-3 text-base',
  };

  return (
    <button
      className={cn(baseClasses, variants[variant], sizes[size], className)}
      {...props}
    >
      {children}
    </button>
  );
};
```

### Responsive Design

```typescript
function ResponsiveComponent() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div className="card">
        <h3 className="text-lg font-semibold">Card 1</h3>
        <p className="text-gray-600">Content for card 1</p>
      </div>
      <div className="card">
        <h3 className="text-lg font-semibold">Card 2</h3>
        <p className="text-gray-600">Content for card 2</p>
      </div>
      <div className="card">
        <h3 className="text-lg font-semibold">Card 3</h3>
        <p className="text-gray-600">Content for card 3</p>
      </div>
    </div>
  );
}
```

## Error Handling

### Error Boundaries

```typescript
// src/components/ErrorBoundary.tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="text-center py-12">
          <h2 className="text-xl font-semibold text-red-600">
            Something went wrong
          </h2>
          <p className="text-gray-600 mt-2">
            Please try refreshing the page
          </p>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Async Error Handling

```typescript
import { useState } from 'react';
import toast from 'react-hot-toast';

export const useAsyncOperation = <T,>(
  operation: () => Promise<T>
) => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const execute = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const result = await operation();
      return result;
    } catch (err) {
      const error = err as Error;
      setError(error);
      toast.error(error.message);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  return { execute, isLoading, error };
};
```

## Testing

### Component Testing

```typescript
// src/components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../ui/Button';

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies variant classes', () => {
    render(<Button variant="danger">Delete</Button>);
    const button = screen.getByText('Delete');
    expect(button).toHaveClass('bg-red-600');
  });
});
```

### Hook Testing

```typescript
// src/hooks/__tests__/useWalletInfo.test.ts
import { renderHook } from '@testing-library/react';
import { useWalletInfo } from '../useWalletInfo';

// Mock wagmi hooks
jest.mock('wagmi', () => ({
  useAccount: () => ({
    address: '0x123...',
    isConnected: true,
  }),
  useBalance: () => ({
    data: { formatted: '1.0', symbol: 'ETH' },
    isLoading: false,
  }),
}));

describe('useWalletInfo', () => {
  it('returns wallet information', () => {
    const { result } = renderHook(() => useWalletInfo());
    
    expect(result.current.address).toBe('0x123...');
    expect(result.current.isConnected).toBe(true);
    expect(result.current.balance?.formatted).toBe('1.0');
  });
});
```

## Performance Optimization

### React.memo

```typescript
import React from 'react';

interface ExpensiveComponentProps {
  data: any[];
  onItemClick: (item: any) => void;
}

export const ExpensiveComponent = React.memo<ExpensiveComponentProps>(
  ({ data, onItemClick }) => {
    return (
      <div>
        {data.map((item, index) => (
          <div key={index} onClick={() => onItemClick(item)}>
            {item.name}
          </div>
        ))}
      </div>
    );
  }
);
```

### useMemo and useCallback

```typescript
import { useMemo, useCallback } from 'react';

function OptimizedComponent({ items, onFilter }) {
  const filteredItems = useMemo(() => {
    return items.filter(item => item.active);
  }, [items]);

  const handleItemClick = useCallback((item) => {
    onFilter(item.id);
  }, [onFilter]);

  return (
    <div>
      {filteredItems.map(item => (
        <div key={item.id} onClick={() => handleItemClick(item)}>
          {item.name}
        </div>
      ))}
    </div>
  );
}
```

## Build and Deployment

### Build Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          wagmi: ['wagmi', '@wagmi/core'],
        },
      },
    },
  },
});
```

### Environment Variables

```typescript
// src/config/environment.ts
export const config = {
  civic: {
    clientId: import.meta.env.VITE_CIVIC_CLIENT_ID,
    redirectUri: import.meta.env.VITE_CIVIC_REDIRECT_URI,
  },
  blockchain: {
    rpcUrl: import.meta.env.VITE_RPC_URL,
    chainId: import.meta.env.VITE_CHAIN_ID,
    contractAddress: import.meta.env.VITE_CONTRACT_ADDRESS,
  },
  app: {
    name: import.meta.env.VITE_APP_NAME || 'Web3 Starter Kit',
    version: import.meta.env.VITE_APP_VERSION || '1.0.0',
  },
};
```

## Resources

- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Wagmi Documentation](https://wagmi.sh/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Vite Documentation](https://vitejs.dev/)

## Best Practices

1. **Component Structure**
   - Use functional components with hooks
   - Keep components small and focused
   - Use TypeScript for type safety

2. **State Management**
   - Use React Context for global state
   - Prefer local state when possible
   - Use Zustand for complex state

3. **Performance**
   - Use React.memo for expensive components
   - Implement proper dependency arrays
   - Optimize bundle size

4. **Testing**
   - Write tests for critical functionality
   - Use React Testing Library
   - Mock external dependencies

5. **Accessibility**
   - Use semantic HTML
   - Implement keyboard navigation
   - Add ARIA labels where needed 
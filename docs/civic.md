# Civic Authentication Integration

This guide covers integrating Civic authentication into the Web3 Starter Kit.

## Overview

Civic provides Web3 authentication with multiple login options:
- **SSO Integration** - Google, Apple, X, Facebook, Discord, GitHub
- **Email Authentication** - Traditional email/password
- **Wallet Integration** - Embedded wallet capabilities
- **Multi-chain Support** - Works across major blockchains

## Setup

### 1. Civic Dashboard Setup

1. Go to [Civic Dashboard](https://auth.civic.com)
2. Create a new application
3. Configure your application settings:
   - **App Name**: Web3 Starter Kit
   - **Redirect URI**: `http://localhost:3000/auth/callback`
   - **Supported Chains**: Ethereum, Polygon, Arbitrum
4. Copy your Client ID

### 2. Environment Configuration

Add your Civic credentials to `.env`:

```env
VITE_CIVIC_CLIENT_ID=your_civic_client_id_here
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback
```

### 3. Install Civic SDK

```bash
npm install @civic/auth-web3
```

## Integration

### 1. Civic Provider Setup

```typescript
import { CivicAuthProvider } from '@civic/auth-web3/react';

function App() {
  return (
    <CivicAuthProvider
      clientId={process.env.VITE_CIVIC_CLIENT_ID}
      onSignIn={(error?: Error) => {
        if (error) {
          console.error('Civic sign-in error:', error);
        } else {
          console.log('Civic sign-in successful');
        }
      }}
      onSignOut={() => {
        console.log('Civic sign-out successful');
      }}
    >
      {/* Your app components */}
    </CivicAuthProvider>
  );
}
```

### 2. Using the UserButton Component

The Civic SDK provides a pre-built UserButton component:

```typescript
import { UserButton } from '@civic/auth-web3/react';

function Header() {
  return (
    <header>
      <h1>My App</h1>
      <UserButton 
        className="civic-user-button"
        dropdownButtonClassName="civic-dropdown-button"
      />
    </header>
  );
}
```

### 3. Using the useUser Hook

```typescript
import { useUser } from '@civic/auth-web3/react';

function MyComponent() {
  const { user, authStatus, signIn, signOut, isLoading, error } = useUser();

  if (authStatus === 'authenticating') {
    return <div>Loading...</div>;
  }

  if (!user) {
    return (
      <button onClick={() => signIn()}>
        Sign In with Civic
      </button>
    );
  }

  return (
    <div>
      <h2>Welcome, {user.name}!</h2>
      <button onClick={() => signOut()}>Sign Out</button>
    </div>
  );
}
```

## User Object Structure

The Civic user object contains:

```typescript
interface CivicUser {
  id: string;
  email?: string;
  name?: string;
  picture?: string;
  given_name?: string;
  family_name?: string;
  updated_at?: Date;
}
```

## Authentication Status

The `authStatus` field can have the following values:

```typescript
enum AuthStatus {
  AUTHENTICATED = "authenticated",
  UNAUTHENTICATED = "unauthenticated", 
  AUTHENTICATING = "authenticating",
  ERROR = "error",
  SIGNING_OUT = "signing_out",
}
```

## Custom Styling

### CSS Classes

Add custom styling for the UserButton:

```css
.civic-user-button .login-button {
  @apply bg-blue-600 text-white px-4 py-2 rounded-md font-medium transition-colors hover:bg-blue-700;
}

.civic-user-button .internal-button {
  @apply bg-gray-100 text-gray-700 px-3 py-2 rounded-md font-medium transition-colors hover:bg-gray-200;
}

.civic-dropdown-button {
  @apply bg-white text-gray-700 px-3 py-2 rounded-md font-medium transition-colors hover:bg-gray-50 border border-gray-200;
}
```

### Inline Styles

```typescript
<UserButton 
  style={{ minWidth: "20rem" }} 
  dropdownButtonStyle={{ backgroundColor: "red" }} 
/>
```

## Configuration Options

### CivicAuthProvider Props

```typescript
<CivicAuthProvider
  clientId="your_client_id"           // Required
  onSignIn={(error?: Error) => {}}    // Optional callback
  onSignOut={() => {}}                // Optional callback
  redirectUrl="/authenticating"       // Optional redirect URL
  iframeMode="embedded"               // Optional: "embedded" | "modal"
  displayMode="iframe"                // Optional: "iframe" | "redirect" | "new_tab"
/>
```

### Display Modes

- **"iframe"** (default): Authentication happens in an embedded window
- **"redirect"**: Full page navigation to auth server
- **"new_tab"**: Opens auth flow in a new browser tab

## Error Handling

### Common Errors

```typescript
const { error } = useUser();

if (error) {
  console.error('Civic error:', error.message);
  // Handle error appropriately
}
```

### Error Types

- `USER_CANCELLED` - User cancelled the login process
- `NETWORK_ERROR` - Network connectivity issues
- `INVALID_CLIENT_ID` - Invalid Civic client ID
- `INVALID_REDIRECT_URI` - Mismatched redirect URI
- `AUTHENTICATION_FAILED` - Authentication process failed

## Testing

### Test Component

```typescript
import { CivicTest } from './components/civic/CivicTest';

function TestPage() {
  return (
    <div>
      <h1>Civic Authentication Test</h1>
      <CivicTest />
    </div>
  );
}
```

### Unit Tests

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { CivicAuthProvider, useUser } from '@civic/auth-web3/react';

const TestComponent = () => {
  const { signIn, authStatus } = useUser();
  
  return (
    <button onClick={signIn} data-testid="login-button">
      {authStatus === 'authenticated' ? 'Logged In' : 'Login'}
    </button>
  );
};

test('Civic login integration', () => {
  render(
    <CivicAuthProvider clientId="test">
      <TestComponent />
    </CivicAuthProvider>
  );
  
  const button = screen.getByTestId('login-button');
  expect(button).toHaveTextContent('Login');
});
```

## Deployment

### Production Setup

1. **Update Civic Dashboard**
   - Change redirect URI to production URL
   - Update app settings for production
   - Configure proper CORS settings

2. **Environment Variables**
   ```env
   VITE_CIVIC_CLIENT_ID=your_production_client_id
   VITE_CIVIC_REDIRECT_URI=https://yourdomain.com/auth/callback
   ```

3. **SSL Certificate**
   - Ensure HTTPS is properly configured
   - Update redirect URIs to use HTTPS

## Troubleshooting

### Common Issues

1. **Redirect URI Mismatch**
   - Ensure redirect URI in Civic dashboard matches your app
   - Check for trailing slashes and protocol differences

2. **CORS Errors**
   - Configure allowed origins in Civic dashboard
   - Check browser console for CORS errors

3. **Authentication Failures**
   - Verify client ID is correct
   - Check network connectivity
   - Ensure Civic service is available

4. **User Not Authenticated**
   - Check if user completed OAuth flow
   - Verify callback handling
   - Check for JavaScript errors

### Debug Commands

```bash
# Check Civic SDK version
npm list @civic/auth-web3

# Verify environment variables
echo $VITE_CIVIC_CLIENT_ID

# Test Civic connectivity
curl https://api.civic.com/health
```

## Resources

- [Civic Documentation](https://docs.civic.com/)
- [Civic Dashboard](https://auth.civic.com)
- [OAuth 2.0 Specification](https://tools.ietf.org/html/rfc6749)
- [Web3 Authentication Best Practices](https://ethereum.org/developers/docs/standards/)

## Support

- Civic Support: [support@civic.com](mailto:support@civic.com)
- Documentation: [docs.civic.com](https://docs.civic.com/)
- Community: [Discord](https://discord.gg/civic) 
# Civic Authentication Integration

This guide covers integrating Civic authentication into the Web3 Starter Kit using the official Civic documentation.

## Overview

Civic provides Web3 authentication with multiple login options:
- **SSO Integration** - Google, Apple, X, Facebook, Discord, GitHub
- **Email Authentication** - Traditional email/password
- **Embedded Wallet** - Users can create and manage wallets directly in your app
- **Multi-chain Support** - Works across major blockchains

## Quick Start

A working example is available in our [github examples repo](https://github.com/civicteam/civic-auth-examples/tree/main/packages/civic-auth/reactjs).

### Basic Setup

```tsx
import { CivicAuthProvider, UserButton } from "@civic/auth-web3/react";

function App({ children }) {
  return (
    <CivicAuthProvider clientId="YOUR CLIENT ID">
      <UserButton />
      {children}
    </CivicAuthProvider>
  )
}
```

## Setup

### 1. Civic Dashboard Setup

1. Go to [Civic Dashboard](https://auth.civic.com)
2. Create a new application
3. Configure your application settings:
   - **App Name**: Web3 Starter Kit
   - **Redirect URI**: `http://localhost:3000/auth/callback`
   - **Supported Chains**: Ethereum, Polygon, Arbitrum
4. **Enable Embedded Wallet**: 
   - Go to Settings → Embedded Wallet
   - Enable the embedded wallet feature for your users
   - This allows users to create and manage wallets directly in your app
5. Copy your Client ID

### 2. Environment Configuration

Add your Civic credentials to `frontend/.env`:

```env
VITE_CIVIC_CLIENT_ID=your_civic_client_id_here
VITE_CIVIC_REDIRECT_URI=http://localhost:3000/auth/callback
```

### 3. Install Civic SDK

```bash
npm install @civic/auth-web3
```

## The User Button

The Civic Auth SDK comes with a multi-purpose styled component called the `UserButton`:

```tsx
import { UserButton, CivicAuthProvider } from "@civic/auth-web3/react";

export function TitleBar() {
  return (
    <div>
      <h1>My App</h1>
      <UserButton />
    </div>
  );
};
```

This component is context-dependent. If the user is logged in, it will show their profile picture and name. If the user is not logged in, it will show a Log In button. The button will show a loading spinner while the user is in the process of signing in or signing out.

### Customizing the User Button

You can customize the styling of the user button by adding either a `className` or `style` property to the UserButton component when declaring it. These styling properties affect both the sign-in button and the user information display when logged in. For further customization, you can also style the buttons that appear in the dropdown menu (which displays when clicking on the user information button) by using the `dropdownButtonClassName` or `dropdownButtonStyle` properties.

Using a className:

```css
.my-button-container .login-button {
  color: red;
  background-color: blue;
  border: 3px solid #6b7280;
}

.my-button-container .internal-button {
  background-color: red;
  color: blue;
  border: 3px solid #6b7280;
}
```

```tsx
import { UserButton, CivicAuthProvider } from "@civic/auth-web3/react";

export function TitleBar() {
  return (
    <div className="my-button-container">
      <UserButton className="login-button" dropdownButtonClassName="internal-button" />
    </div>
  );
};
```

Using styles:

```tsx
import { UserButton, CivicAuthProvider } from "@civic/auth-web3/react";

export function TitleBar() {
  return (
    <div>
      <UserButton style={{ minWidth: "20rem" }} dropdownButtonStyle={{ backgroundColor: "red" }} />
    </div>
  );
};
```

## Getting User Information

Use the Civic Auth SDK to retrieve user information on the frontend:

```tsx
import { useUser } from "@civic/auth-web3/react";

export function MyComponent() {
  const { user } = useUser();

  if (!user) return <div>User not logged in</div>

  return <div>Hello { user.name }!</div>
}
```

### Creating your own Login and Logout buttons

You can use the `signIn()` and `signOut()` methods from the `useUser()` hook to create your own buttons for user login and logout:

```tsx
import { useUser } from "@civic/auth-web3/react";

export function TitleBar() {
  const { user, signIn, signOut } = useUser();
  return (
    <div className="flex justify-between items-center">
      <h1>My App</h1>
      {!user && <button onClick={signIn} className="sign-in">Sign into My App</button>}
      {user && <button onClick={signOut} className="sign-out">Sign out of My App</button>}
    </div>
  );
};
```

## Web3 Wallet Integration

### Creating a Wallet

When a new user logs in, they do not yet have a Web3 wallet by default. You can create a wallet for them by calling the `createWallet` function on the user object.

**Note**: Currently, we don't support connecting users' existing self-custodial wallets. This is coming soon. Right now, we only support embedded wallets, which are generated on behalf of the user by our non-custodial wallet partner.

Here's a basic example:

```tsx
import { userHasWallet } from "@civic/auth-web3";
import { useUser } from "@civic/auth-web3/react";

export const afterLogin = async () => {
  const userContext = await useUser();

  if (userContext.user && !userHasWallet(userContext)) {
    await userContext.createWallet();
  }
};
```

### The useUser hook and UserContext Object

The useUser hook returns a user context object that provides access to the base library's user object in the 'user' field, and adds some Web3 specific fields. The returned object has different types depending on these cases:

If the user has a wallet:

```tsx
type ExistingWeb3UserContext = UserContext & {
  ethereum: {
      address: string // the address of the embedded wallet
      wallet: WalletClient // a Viem WalletClient
  }
}
```

If the user does not yet have a wallet:

```tsx
type NewWeb3UserContext = UserContext & {
  createWallet: () => Promise<void>;
  walletCreationInProgress: boolean;
}
```

An easy way to distinguish between the two is to use the `userHasWallet` type guard:

```tsx
if (userHasWallet(userContext)) {
  user.ethereum.wallet; // user has a wallet
} else {
  user.createWallet(); // user does not have a wallet
}
```

## Using the Wallet with Wagmi

To use the embedded wallet with Wagmi, follow these steps:

### 1. Add the Embedded Wallet to Wagmi Config

Include `embeddedWallet()` in your Wagmi configuration:

```tsx
import { embeddedWallet } from "@civic/auth-web3/wagmi";
import { mainnet } from "viem/chains";
import { Chain, http } from "viem";
import { createConfig, WagmiProvider } from "wagmi";

const wagmiConfig = createConfig({
  chains: [mainnet],
  transports: {
      [mainnet.id]: http()
  },
  connectors: [
    embeddedWallet(),
  ],
});
```

### 2. Connect the wallet

#### Autoconnect

If you want to automatically connect the civic wallet as soon as the user has logged in, you can use the `useAutoConnect()` hook:

```tsx
import { useAutoConnect } from "@civic/auth-web3/wagmi";

useAutoConnect();
```

This hook also creates the wallet, if it is a new user.

#### Manual

If you want a little more control, first create the wallet:

```tsx
import { userHasWallet } from "@civic/auth-web3";
import { embeddedWallet } from "@civic/auth-web3/wagmi";
import { CivicAuthProvider, UserButton, useUser } from "@civic/auth-web3/react";

// A function that creates the wallet if the user doesn't have one already
const createWallet = () => {
  if (userContext.user && !userHasWallet(userContext)) {
    // Once the wallet is created, we can connect to it
    return userContext.createWallet().then(connectWallet)
  }
}
```

Then initiate the connection to the embedded wallet using Wagmi's `connect` method:

```tsx
const { connectors, connect } = useConnect();

const connectWallet = () => connect({
  // connect to the "civic" connector
  connector: connectors[0],
});
```

### 3. Use Wagmi Hooks

Once connected, you can use Wagmi hooks to interact with the embedded wallet. Common hooks include:

- `useBalance`: Retrieve the wallet balance.
- `useAccount`: Access account details.
- `useSendTransaction`: Send transactions from the wallet.
- `useSignMessage`: Sign messages with the wallet.

### A Full Example

```tsx
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiProvider, createConfig, useAccount, useConnect, useBalance, http } from "wagmi";
import { userHasWallet } from "@civic/auth-web3";
import { embeddedWallet } from "@civic/auth-web3/wagmi";
import { CivicAuthProvider, UserButton, useUser } from "@civic/auth-web3/react";
import { mainnet, sepolia } from "wagmi/chains";

const wagmiConfig = createConfig({
  chains: [ mainnet, sepolia ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
  connectors: [
    embeddedWallet(),
  ],
});

// Wagmi requires react-query
const queryClient = new QueryClient();

// Wrap the content with the necessary providers to give access to hooks: react-query, wagmi & civic auth provider
// initialChain is passed into <CivicAuthProvider /> to indicate the first chain you want to use.
// The chain can be switched later using wagmi's useSwitchChain() hook.
const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiProvider config={wagmiConfig}>
        <CivicAuthProvider clientId="< YOUR CLIENT ID >" initialChain={mainnet}>
          <AppContent />
        </CivicAuthProvider>
      </WagmiProvider>
    </QueryClientProvider>
  );
};

// Separate component for the app content that needs access to hooks
const AppContent = () => {
  // Add the civic hooks
  const userContext = useUser();
  useAutoConnect();

  // Add the wagmi hooks
  const { isConnected, address } = useAccount();
  const balance = useBalance({ address });

  return (
    <>
      <UserButton />
      {userContext.user &&
        <div>
          {!userHasWallet(userContext) &&
            <p><button onClick={createWallet}>Create Wallet</button></p>
          }
          {userHasWallet(userContext) &&
            <>
              <p>Wallet address: {userContext.eth.address}</p>
              <p>Balance: {
                balance?.data
                  ? `${(BigInt(balance.data.value) / BigInt(1e18)).toString()} ${balance.data.symbol}`
                  : "Loading..."
              }</p>
              {isConnected ? <p>Wallet is connected</p> : (
                <button onClick={connectExistingWallet}>Connect Wallet</button>
              )}
            </>
          }
        </div>
      }
    </>
  );
};

export default App;
```

## Using the Wallet with Viem

If you are not using Wagmi, you may also use [Viem](https://viem.sh) directly to access the same wallet capabilities:

```tsx
const userContext = useUser();

if (userContext.user && userHasWallet(userContext)) {
  const { wallet } = userContext.ethereum;
  const hash = await wallet.sendTransaction({
    to: "0x...",
    value: 1000n
  })
}
```

## Advanced Configuration

Civic Auth is a "low-code" solution, so all configuration takes place via the [dashboard](https://auth.civic.com). Changes you make there will be updated automatically in your integration without any code changes. The only required parameter you need to provide is the client ID.

The integration provides additional run-time settings and hooks that you can use to customize the library's integration with your own app. If you need any of these, you can add them to the CivicAuthProvider as follows:

```tsx
<CivicAuthProvider
  clientId="YOUR CLIENT ID"
  ...other configuration
>
```

### Configuration Options

| Field | Required | Default | Example | Description |
|-------|----------|---------|---------|-------------|
| clientId | Yes | - | `2cc5633d-2c92-48da-86aa-449634f274b9` | The key obtained on signup to [auth.civic.com](https://auth.civic.com) |
| nonce | No | - | 1234 | A single-use ID used during login, binding a login token with a given client. Needed in advanced authentication processes only |
| onSignIn | No | - | `(error?: Error) => { if (error) { // handle error } else { // handle successful login } }` | A hook that executes after a sign-in attempt, whether successful or not. |
| onSignOut | No | - | `() => { // handle signout }` | A hook that executes after a user logs out. |
| redirectUrl | No | currentURL | /authenticating | An override for the page that OAuth will redirect to to perform token-exchange. By default Civic will redirect to the current URL and Authentication will be finished by the Civic provider automatically. Only use if you'd like to have some custom display or logic during OAuth token-exchange. The redirect page must have the CivicAuthProvider running in order to finish authentication. |
| iframeMode | No | modal | iframeMode={"embedded"} | Set to `embedded` if you want to embed the login iframe in your app rather than opening the iframe in a modal. |
| displayMode | No | iFrame | "iframe" \| "redirect" \| "new_tab" | **"iframe"**: Authentication happens in an embedded window within your current page.<br />**"redirect"**: Full page navigation to the auth server and back to your site after completion.<br />**"new_tab"**: Opens auth flow in a new browser tab, returning to original tab after completion. |

### Display Mode

The display mode indicates where the Civic login UI will be displayed. The following display modes are supported:

- `iframe` (default): the UI loads in an iframe that shows in an overlay on top of the existing page content
- `redirect`: the UI redirects the current URL to a Civic login screen, then redirects back to your site when login is complete
- `new_tab`: the UI opens in a new tab or popup window (depending on browser preferences), and after login is complete, the tab or popup closes to return the user to your site

### Limiting to specific chains

By default, Civic Auth supports all chains supported by viem. If you want to restrict wallet usage to specific chains, you can pass an array of chains to the CivicAuthProvider. Pass the `initialChain` property to define the chain you want to start using.

#### Example 1. Using viem chain objects

```tsx
import { mainnet, polygon } from "viem/chains";
<CivicAuthProvider chains={[mainnet, polygon]} initialChain={mainnet}>
```

#### The chain can be switched using wagmi's useSwitchChain hook:

```tsx
import { useSwitchChain } from "wagmi";

// Switch chain to polygon
switchChain({
   chainId: polygon.id,
});
```

#### Example 2. Specifying custom RPCs

```tsx
import { mainnet, polygon } from "viem/chains";
<CivicAuthProvider endpoints={{
    rpcs: {
        [mainnet.id]: {
            http: [<your mainnet HTTP RPC URL>],
            webSocket: [<your mainnet WS RPC URL>], // or omit if not available
        },
        [polygon.id]: {
            http: [<your polygon HTTP RPC URL>],
            webSocket: [<your polygon WS RPC URL>], // or omit if not available
        }
    }
}}>
```

## API Reference

### User Context

The full user context object (provided by `useUser`) looks like this:

```js
{
  user: User | null;
  // these are the OAuth tokens created during authentication
  idToken?: string;
  accessToken?: string;
  refreshToken?: string;
  forwardedTokens?: ForwardedTokens;
  // functions and flags for UI and signIn/signOut
  isLoading: boolean;
  authStatus: AuthStatus;
  error: Error | null;
  signIn: (displayMode?: DisplayMode) => Promise<void>;
  signOut: () => Promise<void>;
}
```

#### AuthStatus

The `authStatus` field exposed in the UserContext can be used to update your UI depending on the user's authentication status, i.e. update the UI to show a loader while the user is in the process of authenticating or signing out.

```json
export enum AuthStatus {
  AUTHENTICATED = "authenticated",
  UNAUTHENTICATED = "unauthenticated",
  AUTHENTICATING = "authenticating",
  ERROR = "error",
  SIGNING_OUT = "signing_out",
}
```

### User

The `User` object looks like this:

```json
type BaseUser = {
  id: string;
  email?: string;
  name?: string;
  picture?: string;
  given_name?: string;
  family_name?: string;
  updated_at?: Date;
};

type User = BaseUser & T;
```

Where you can pass extra user attributes to the object that you know will be present in user claims, e.g.

```json
const UserWithNickName = User<{ nickname: string }>;
```

#### Base User Fields

| Field | Description |
|-------|-------------|
| id | The user's unique ID with respect to your app. You can use this to look up the user in the [dashboard](https://auth.civic.com/dashboard). |
| email | The user's email address |
| name | The user's full name |
| given_name | The user's given name |
| family_name | The user's family name |
| updated_at | The time at which the user's profile was most recently updated. |

#### Token Fields

Typically developers will not need to interact with the token fields, which are used only for advanced use cases.

| Field | Description |
|-------|-------------|
| idToken | The OIDC id token, used to request identity information about the user |
| accessToken | The OAuth 2.0 access token, allowing a client to make API calls to Civic Auth on behalf of the user. |
| refreshToken | The OAuth 2.0 refresh token, allowing a login session to be extended automatically without requiring user interaction. The Civic Auth SDK handles refresh automatically, so you do not need to do this. |
| forwardedTokens | If the user authenticated using SSO (single-sign-on login) with a federated OAuth provider such as Google, this contains the OIDC and OAuth 2.0 tokens from that provider. |

#### Forwarded Tokens

Use forwardedTokens if you need to make requests to the source provider, such as find out provider-specific information.

An example would be, if a user logged in via Google, using the Google forwarded token to query the Google Groups that the user is a member of.

For example:

```tsx
const googleAccessToken = user.forwardedTokens?.google?.accessToken;
```

## Embedded Login Iframe

If you want to have the Login screen open directly on a page without the user having to click on button, you can import the `CivicAuthIframeContainer` component along with the AuthProvider option `iframeMode={"embedded"}`. You just need to ensure that the `CivicAuthIframeContainer` is a child under a `CivicAuthProvider`:

```tsx
import { CivicAuthIframeContainer } from "@civic/auth-web3/react";

const Login = () => {
  return (
      <div className="login-container">
        <CivicAuthIframeContainer />
      </div>
  );
};

const App = () => {
  return (
      <CivicAuthProvider
        clientId={"YOUR CLIENT ID"}
        iframeMode={"embedded"}
      >
        <Login />
      </CivicAuthProvider>
  );
}
```

## Resources

- [Civic Documentation](https://docs.civic.com/)
- [Civic Dashboard](https://auth.civic.com)
- [GitHub Examples](https://github.com/civicteam/civic-auth-examples)
- [Wagmi Documentation](https://wagmi.sh/)
- [Viem Documentation](https://viem.sh/)

## Support

- Civic Support: [support@civic.com](mailto:support@civic.com)
- Documentation: [docs.civic.com](https://docs.civic.com/)
- Community: [Discord](https://discord.gg/civic) 
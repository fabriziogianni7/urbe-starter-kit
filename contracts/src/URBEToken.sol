// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title URBEToken
 * @dev A comprehensive ERC20 token contract with advanced features including:
 * - Minting and burning functionality
 * - Pausable functionality for emergencies
 * - Role-based access control
 * - Owner and authorized minter minting
 * - Custom errors for gas optimization
 * - Comprehensive events for state changes
 * 
 * @author URBE Starter Kit
 * @notice This contract implements a full-featured ERC20 token with security best practices
 */
contract URBEToken is ERC20, Ownable, Pausable, ReentrancyGuard, AccessControl {
    // ============ Constants ============
    
    /// @notice Role for authorized minters
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /// @notice Role for authorized burners
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    /// @notice Role for pausers
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    // ============ State Variables ============
    
    /// @notice Maximum supply of tokens
    uint256 public immutable maxSupply;
    
    /// @notice Flag to enable/disable minting
    bool public mintingEnabled;
    
    /// @notice Flag to enable/disable burning
    bool public burningEnabled;
    
    /// @notice Flag to enable/disable pausing
    bool public pausingEnabled;
    
    // ============ Custom Errors ============
    
    /// @notice Error thrown when minting is disabled
    error MintingDisabled();
    
    /// @notice Error thrown when burning is disabled
    error BurningDisabled();
    
    /// @notice Error thrown when pausing is disabled
    error PausingDisabled();
    
    /// @notice Error thrown when max supply would be exceeded
    error MaxSupplyExceeded();
    
    /// @notice Error thrown when amount is zero
    error ZeroAmount();
    
    /// @notice Error thrown when address is zero
    error ZeroAddress();
    
    /// @notice Error thrown when insufficient balance for burning
    error InsufficientBalance();
    
    // ============ Events ============
    
    /// @notice Emitted when minting is enabled/disabled
    event MintingToggled(bool enabled, address indexed by);
    
    /// @notice Emitted when burning is enabled/disabled
    event BurningToggled(bool enabled, address indexed by);
    
    /// @notice Emitted when pausing is enabled/disabled
    event PausingToggled(bool enabled, address indexed by);
    
    /// @notice Emitted when max supply is set
    event MaxSupplySet(uint256 maxSupply);
    
    /// @notice Emitted when tokens are minted
    event TokensMinted(address indexed to, uint256 amount, address indexed by);
    
    /// @notice Emitted when tokens are burned
    event TokensBurned(address indexed from, uint256 amount, address indexed by);
    
    /// @notice Emitted when tokens are burned from a specific address
    event TokensBurnedFrom(address indexed from, uint256 amount, address indexed by);
    
    // ============ Constructor ============
    
    /**
     * @notice Initializes the URBEToken contract
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initialSupply The initial supply of tokens
     * @param maxSupply_ The maximum supply of tokens
     * @param initialOwner The initial owner of the contract
     * @param mintingEnabled_ Whether minting is initially enabled
     * @param burningEnabled_ Whether burning is initially enabled
     * @param pausingEnabled_ Whether pausing is initially enabled
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint256 maxSupply_,
        address initialOwner,
        bool mintingEnabled_,
        bool burningEnabled_,
        bool pausingEnabled_
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        if (maxSupply_ == 0) revert ZeroAmount();
        if (initialSupply > maxSupply_) revert MaxSupplyExceeded();
        
        maxSupply = maxSupply_;
        mintingEnabled = mintingEnabled_;
        burningEnabled = burningEnabled_;
        pausingEnabled = pausingEnabled_;
        
        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(MINTER_ROLE, initialOwner);
        _grantRole(BURNER_ROLE, initialOwner);
        _grantRole(PAUSER_ROLE, initialOwner);
        
        // Mint initial supply to owner
        if (initialSupply > 0) {
            _mint(initialOwner, initialSupply);
        }
        
        emit MaxSupplySet(maxSupply_);
        emit MintingToggled(mintingEnabled_, initialOwner);
        emit BurningToggled(burningEnabled_, initialOwner);
        emit PausingToggled(pausingEnabled_, initialOwner);
    }
    
    // ============ External Functions ============
    
    /**
     * @notice Mints tokens to a specified address (owner only)
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
        whenNotPaused 
    {
        _mintTokens(to, amount);
    }
    
    /**
     * @notice Mints tokens to a specified address (authorized minter)
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mintByMinter(address to, uint256 amount) 
        external 
        onlyRole(MINTER_ROLE) 
        nonReentrant 
        whenNotPaused 
    {
        _mintTokens(to, amount);
    }
    
    /**
     * @notice Burns tokens from the caller's address
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) 
        external 
        nonReentrant 
        whenNotPaused 
    {
        _burnTokens(msg.sender, amount);
    }
    
    /**
     * @notice Burns tokens from a specified address (authorized burner)
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) 
        external 
        onlyRole(BURNER_ROLE) 
        nonReentrant 
        whenNotPaused 
    {
        _burnTokensFrom(from, amount);
    }
    
    /**
     * @notice Pauses all token transfers
     */
    function pause() 
        external 
        onlyRole(PAUSER_ROLE) 
        whenNotPaused 
    {
        if (!pausingEnabled) revert PausingDisabled();
        _pause();
    }
    
    /**
     * @notice Unpauses all token transfers
     */
    function unpause() 
        external 
        onlyRole(PAUSER_ROLE) 
        whenPaused 
    {
        if (!pausingEnabled) revert PausingDisabled();
        _unpause();
    }
    
    // ============ Owner Functions ============
    
    /**
     * @notice Toggles minting functionality (owner only)
     * @param enabled Whether to enable or disable minting
     */
    function toggleMinting(bool enabled) external onlyOwner {
        mintingEnabled = enabled;
        emit MintingToggled(enabled, msg.sender);
    }
    
    /**
     * @notice Toggles burning functionality (owner only)
     * @param enabled Whether to enable or disable burning
     */
    function toggleBurning(bool enabled) external onlyOwner {
        burningEnabled = enabled;
        emit BurningToggled(enabled, msg.sender);
    }
    
    /**
     * @notice Toggles pausing functionality (owner only)
     * @param enabled Whether to enable or disable pausing
     */
    function togglePausing(bool enabled) external onlyOwner {
        pausingEnabled = enabled;
        emit PausingToggled(enabled, msg.sender);
    }
    
    /**
     * @notice Grants minter role to an address (owner only)
     * @param minter The address to grant minter role to
     */
    function grantMinterRole(address minter) external onlyOwner {
        if (minter == address(0)) revert ZeroAddress();
        _grantRole(MINTER_ROLE, minter);
    }
    
    /**
     * @notice Revokes minter role from an address (owner only)
     * @param minter The address to revoke minter role from
     */
    function revokeMinterRole(address minter) external onlyOwner {
        if (minter == address(0)) revert ZeroAddress();
        _revokeRole(MINTER_ROLE, minter);
    }
    
    /**
     * @notice Grants burner role to an address (owner only)
     * @param burner The address to grant burner role to
     */
    function grantBurnerRole(address burner) external onlyOwner {
        if (burner == address(0)) revert ZeroAddress();
        _grantRole(BURNER_ROLE, burner);
    }
    
    /**
     * @notice Revokes burner role from an address (owner only)
     * @param burner The address to revoke burner role from
     */
    function revokeBurnerRole(address burner) external onlyOwner {
        if (burner == address(0)) revert ZeroAddress();
        _revokeRole(BURNER_ROLE, burner);
    }
    
    /**
     * @notice Grants pauser role to an address (owner only)
     * @param pauser The address to grant pauser role to
     */
    function grantPauserRole(address pauser) external onlyOwner {
        if (pauser == address(0)) revert ZeroAddress();
        _grantRole(PAUSER_ROLE, pauser);
    }
    
    /**
     * @notice Revokes pauser role from an address (owner only)
     * @param pauser The address to revoke pauser role from
     */
    function revokePauserRole(address pauser) external onlyOwner {
        if (pauser == address(0)) revert ZeroAddress();
        _revokeRole(PAUSER_ROLE, pauser);
    }
    
    // ============ View Functions ============
    
    /**
     * @notice Returns the remaining mintable supply
     * @return The amount of tokens that can still be minted
     */
    function remainingMintableSupply() external view returns (uint256) {
        return maxSupply - totalSupply();
    }
    
    /**
     * @notice Checks if an address has minter role
     * @param account The address to check
     * @return True if the address has minter role
     */
    function isMinter(address account) external view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }
    
    /**
     * @notice Checks if an address has burner role
     * @param account The address to check
     * @return True if the address has burner role
     */
    function isBurner(address account) external view returns (bool) {
        return hasRole(BURNER_ROLE, account);
    }
    
    /**
     * @notice Checks if an address has pauser role
     * @param account The address to check
     * @return True if the address has pauser role
     */
    function isPauser(address account) external view returns (bool) {
        return hasRole(PAUSER_ROLE, account);
    }
    
    // ============ Internal Functions ============
    
    /**
     * @notice Internal function to mint tokens
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function _mintTokens(address to, uint256 amount) internal {
        if (!mintingEnabled) revert MintingDisabled();
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (totalSupply() + amount > maxSupply) revert MaxSupplyExceeded();
        
        _mint(to, amount);
        emit TokensMinted(to, amount, msg.sender);
    }
    
    /**
     * @notice Internal function to burn tokens
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function _burnTokens(address from, uint256 amount) internal {
        if (!burningEnabled) revert BurningDisabled();
        if (amount == 0) revert ZeroAmount();
        if (balanceOf(from) < amount) revert InsufficientBalance();
        
        _burn(from, amount);
        emit TokensBurned(from, amount, msg.sender);
    }
    
    /**
     * @notice Internal function to burn tokens from a specific address
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function _burnTokensFrom(address from, uint256 amount) internal {
        if (!burningEnabled) revert BurningDisabled();
        if (from == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (balanceOf(from) < amount) revert InsufficientBalance();
        
        _burn(from, amount);
        emit TokensBurnedFrom(from, amount, msg.sender);
    }
    
    // ============ Override Functions ============
    
    /**
     * @notice Override _update to include pausable functionality
     * @param from The address sending tokens
     * @param to The address receiving tokens
     * @param value The amount of tokens being transferred
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override whenNotPaused {
        super._update(from, to, value);
    }
    
    /**
     * @notice Override supportsInterface to include AccessControl interface
     * @param interfaceId The interface ID to check
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
} 
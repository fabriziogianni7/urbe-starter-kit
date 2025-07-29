// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {TokenRegistry} from "../src/TokenRegistry.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {URBEToken} from "../src/URBEToken.sol";

/**
 * @title TokenRegistryTest
 * @dev Comprehensive test suite for TokenRegistry contract
 */
contract TokenRegistryTest is Test {
    TokenRegistry public registry;
    TokenFactory public factory;
    URBEToken public testToken;
    
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);
    
    uint256 public constant REGISTRATION_FEE = 0.01 ether;
    uint256 public constant DEPLOYMENT_FEE = 0.01 ether;
    uint256 public constant MAX_TOKENS_PER_CREATOR = 10;
    uint256 public constant MIN_TOKENS_FOR_VERIFICATION = 3;
    uint256 public constant MIN_VOLUME_FOR_VERIFICATION = 1000 * 10**18;
    
    // Token parameters
    string public constant TOKEN_NAME = "Test Token";
    string public constant TOKEN_SYMBOL = "TEST";
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1M tokens
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18; // 10M tokens
    
    event TokenRegistered(
        address indexed tokenAddress,
        string name,
        string symbol,
        address indexed creator,
        uint256 category,
        bool verified
    );
    
    event TokenMetadataUpdated(
        address indexed tokenAddress,
        string name,
        string symbol,
        string description,
        string website,
        string logo
    );
    
    event TokenVerificationUpdated(
        address indexed tokenAddress,
        bool verified,
        address indexed by
    );
    
    event CreatorRegistered(
        address indexed creator,
        string name,
        string description
    );
    
    event CreatorInfoUpdated(
        address indexed creator,
        string name,
        string description
    );
    
    event CreatorVerificationUpdated(
        address indexed creator,
        bool verified,
        address indexed by
    );
    
    event CategoryCreated(
        uint256 indexed categoryId,
        string name,
        string description
    );
    
    event CategoryUpdated(
        uint256 indexed categoryId,
        string name,
        string description,
        bool active
    );
    
    event RegistrationFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
    event RegistryPauseToggled(bool paused, address indexed by);
    event FeesWithdrawn(uint256 amount, address indexed to);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy TokenFactory
        factory = new TokenFactory(owner, DEPLOYMENT_FEE, MAX_TOKENS_PER_CREATOR);
        
        // Deploy TokenRegistry
        registry = new TokenRegistry(
            owner,
            REGISTRATION_FEE,
            address(factory),
            MIN_TOKENS_FOR_VERIFICATION,
            MIN_VOLUME_FOR_VERIFICATION
        );
        
        // Deploy a test token
        testToken = new URBEToken(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            user1,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    // ============ Constructor Tests ============
    
    function test_Constructor_SetsCorrectValues() public {
        assertEq(registry.owner(), owner);
        assertEq(registry.registrationFee(), REGISTRATION_FEE);
        assertEq(registry.tokenFactory(), address(factory));
        assertEq(registry.minTokensForVerification(), MIN_TOKENS_FOR_VERIFICATION);
        assertEq(registry.minVolumeForVerification(), MIN_VOLUME_FOR_VERIFICATION);
        assertEq(registry.totalTokensRegistered(), 0);
        assertEq(registry.totalCreators(), 0);
        assertEq(registry.totalCategories(), 5); // Default categories
        assertFalse(registry.registryPaused());
    }
    
    function test_Constructor_ZeroAddressOwner() public {
        vm.expectRevert(); // OwnableInvalidOwner error from OpenZeppelin
        new TokenRegistry(
            address(0),
            REGISTRATION_FEE,
            address(factory),
            MIN_TOKENS_FOR_VERIFICATION,
            MIN_VOLUME_FOR_VERIFICATION
        );
    }
    
    function test_Constructor_ZeroAddressTokenFactory() public {
        vm.expectRevert(TokenRegistry.InvalidTokenAddress.selector);
        new TokenRegistry(
            owner,
            REGISTRATION_FEE,
            address(0),
            MIN_TOKENS_FOR_VERIFICATION,
            MIN_VOLUME_FOR_VERIFICATION
        );
    }
    
    // ============ Token Registration Tests ============
    
    function test_RegisterToken_Success() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](2);
        tags[0] = "DeFi";
        tags[1] = "Yield";
        
        vm.expectEmit(true, false, true, true);
        emit TokenRegistered(
            address(testToken),
            TOKEN_NAME,
            TOKEN_SYMBOL,
            user1,
            0, // DeFi category
            false
        );
        
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token for DeFi",
            "https://test.com",
            "https://test.com/logo.png",
            0, // DeFi category
            tags
        );
        
        vm.stopPrank();
        
        // Verify registration
        assertEq(registry.totalTokensRegistered(), 1);
        assertEq(registry.totalCreators(), 1);
        assertTrue(registry.isTokenRegistered(address(testToken)));
        assertTrue(registry.isCreatorRegistered(user1));
        
        // Verify metadata
        TokenRegistry.TokenMetadata memory metadata = registry.getTokenMetadata(address(testToken));
        assertEq(metadata.tokenAddress, address(testToken));
        assertEq(metadata.name, TOKEN_NAME);
        assertEq(metadata.symbol, TOKEN_SYMBOL);
        assertEq(metadata.creator, user1);
        assertEq(metadata.category, 0);
        assertEq(metadata.description, "A test token for DeFi");
        assertEq(metadata.website, "https://test.com");
        assertEq(metadata.logo, "https://test.com/logo.png");
        assertFalse(metadata.verified);
        assertTrue(metadata.active);
        assertEq(metadata.tags.length, 2);
        assertEq(metadata.tags[0], "DeFi");
        assertEq(metadata.tags[1], "Yield");
    }
    
    function test_RegisterToken_InsufficientFee() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        vm.expectRevert(TokenRegistry.InsufficientRegistrationFee.selector);
        registry.registerToken{value: REGISTRATION_FEE - 0.001 ether}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
    }
    
    function test_RegisterToken_AlreadyRegistered() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token first time
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        // Try to register again
        vm.expectRevert(TokenRegistry.TokenAlreadyRegistered.selector);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "Another test token",
            "https://test2.com",
            "https://test2.com/logo.png",
            1,
            tags
        );
        
        vm.stopPrank();
    }
    
    function test_RegisterToken_InvalidCategory() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        vm.expectRevert(TokenRegistry.InvalidCategoryId.selector);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            999, // Invalid category
            tags
        );
        
        vm.stopPrank();
    }
    
    function test_RegisterToken_RegistryPaused() public {
        vm.startPrank(owner);
        registry.setRegistryPaused(true);
        vm.stopPrank();
        
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        vm.expectRevert(TokenRegistry.RegistryPaused.selector);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
    }
    
    function test_RegisterToken_ZeroAddress() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        vm.expectRevert(TokenRegistry.InvalidTokenAddress.selector);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(0),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
    }
    
    // ============ Creator Registration Tests ============
    
    function test_RegisterCreator_Success() public {
        vm.startPrank(user1);
        
        vm.expectEmit(true, false, false, true);
        emit CreatorRegistered(user1, "Test Creator", "A test creator");
        
        registry.registerCreator("Test Creator", "A test creator");
        
        vm.stopPrank();
        
        // Verify registration
        assertEq(registry.totalCreators(), 1);
        assertTrue(registry.isCreatorRegistered(user1));
        
        // Verify creator info
        TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(user1);
        assertEq(info.creator, user1);
        assertEq(info.totalTokens, 0);
        assertEq(info.verifiedTokens, 0);
        assertEq(info.totalVolume, 0);
        assertFalse(info.verified);
        assertEq(info.name, "Test Creator");
        assertEq(info.description, "A test creator");
    }
    
    function test_RegisterCreator_EmptyName() public {
        vm.startPrank(user1);
        
        vm.expectRevert(TokenRegistry.EmptyName.selector);
        registry.registerCreator("", "A test creator");
        
        vm.stopPrank();
    }
    
    function test_RegisterCreator_EmptyDescription() public {
        vm.startPrank(user1);
        
        vm.expectRevert(TokenRegistry.EmptyDescription.selector);
        registry.registerCreator("Test Creator", "");
        
        vm.stopPrank();
    }
    
    function test_UpdateCreatorInfo_Success() public {
        vm.startPrank(user1);
        
        // Register creator first
        registry.registerCreator("Test Creator", "A test creator");
        
        // Update creator info
        vm.expectEmit(true, false, false, true);
        emit CreatorInfoUpdated(user1, "Updated Creator", "An updated creator");
        
        registry.updateCreatorInfo("Updated Creator", "An updated creator");
        
        vm.stopPrank();
        
        // Verify update
        TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(user1);
        assertEq(info.name, "Updated Creator");
        assertEq(info.description, "An updated creator");
    }
    
    function test_UpdateCreatorInfo_NotRegistered() public {
        vm.startPrank(user1);
        
        vm.expectRevert(TokenRegistry.InvalidCreatorAddress.selector);
        registry.updateCreatorInfo("Updated Creator", "An updated creator");
        
        vm.stopPrank();
    }
    
    // ============ Token Metadata Update Tests ============
    
    function test_UpdateTokenMetadata_Success() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token first
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        // Update metadata
        vm.expectEmit(true, false, false, true);
        emit TokenMetadataUpdated(
            address(testToken),
            TOKEN_NAME,
            TOKEN_SYMBOL,
            "Updated description",
            "https://updated.com",
            "https://updated.com/logo.png"
        );
        
        registry.updateTokenMetadata(
            address(testToken),
            "Updated description",
            "https://updated.com",
            "https://updated.com/logo.png"
        );
        
        vm.stopPrank();
        
        // Verify update
        TokenRegistry.TokenMetadata memory metadata = registry.getTokenMetadata(address(testToken));
        assertEq(metadata.description, "Updated description");
        assertEq(metadata.website, "https://updated.com");
        assertEq(metadata.logo, "https://updated.com/logo.png");
    }
    
    function test_UpdateTokenMetadata_NotCreator() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token first
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
        
        // Try to update from different user
        vm.startPrank(user2);
        vm.expectRevert(TokenRegistry.OnlyCreator.selector);
        registry.updateTokenMetadata(
            address(testToken),
            "Updated description",
            "https://updated.com",
            "https://updated.com/logo.png"
        );
        
        vm.stopPrank();
    }
    
    function test_UpdateTokenMetadata_NotRegistered() public {
        vm.startPrank(user1);
        
        vm.expectRevert(TokenRegistry.OnlyCreator.selector);
        registry.updateTokenMetadata(
            address(0x999),
            "Updated description",
            "https://updated.com",
            "https://updated.com/logo.png"
        );
        
        vm.stopPrank();
    }
    
    // ============ Owner Function Tests ============
    
    function test_SetRegistrationFee() public {
        uint256 newFee = 0.02 ether;
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit RegistrationFeeUpdated(REGISTRATION_FEE, newFee, owner);
        registry.setRegistrationFee(newFee);
        vm.stopPrank();
        
        assertEq(registry.registrationFee(), newFee);
    }
    
    function test_SetRegistrationFee_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        registry.setRegistrationFee(0.02 ether);
        vm.stopPrank();
    }
    
    function test_SetRegistryPaused() public {
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit RegistryPauseToggled(true, owner);
        registry.setRegistryPaused(true);
        vm.stopPrank();
        
        assertTrue(registry.registryPaused());
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit RegistryPauseToggled(false, owner);
        registry.setRegistryPaused(false);
        vm.stopPrank();
        
        assertFalse(registry.registryPaused());
    }
    
    function test_SetTokenVerification() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token first
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
        
        // Verify token
        vm.startPrank(owner);
        vm.expectEmit(true, false, true, true);
        emit TokenVerificationUpdated(address(testToken), true, owner);
        registry.setTokenVerification(address(testToken), true);
        vm.stopPrank();
        
        // Verify status
        TokenRegistry.TokenMetadata memory metadata = registry.getTokenMetadata(address(testToken));
        assertTrue(metadata.verified);
        
        // Unverify token
        vm.startPrank(owner);
        vm.expectEmit(true, false, true, true);
        emit TokenVerificationUpdated(address(testToken), false, owner);
        registry.setTokenVerification(address(testToken), false);
        vm.stopPrank();
        
        metadata = registry.getTokenMetadata(address(testToken));
        assertFalse(metadata.verified);
    }
    
    function test_SetCreatorVerification() public {
        vm.startPrank(user1);
        registry.registerCreator("Test Creator", "A test creator");
        vm.stopPrank();
        
        // Verify creator
        vm.startPrank(owner);
        vm.expectEmit(true, false, true, true);
        emit CreatorVerificationUpdated(user1, true, owner);
        registry.setCreatorVerification(user1, true);
        vm.stopPrank();
        
        // Verify status
        TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(user1);
        assertTrue(info.verified);
        
        // Unverify creator
        vm.startPrank(owner);
        vm.expectEmit(true, false, true, true);
        emit CreatorVerificationUpdated(user1, false, owner);
        registry.setCreatorVerification(user1, false);
        vm.stopPrank();
        
        info = registry.getCreatorInfo(user1);
        assertFalse(info.verified);
    }
    
    function test_CreateCategory() public {
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, true);
        emit CategoryCreated(5, "New Category", "A new category");
        registry.createCategory("New Category", "A new category");
        vm.stopPrank();
        
        assertEq(registry.totalCategories(), 6);
        
        TokenRegistry.CategoryInfo memory category = registry.getCategoryInfo(5);
        assertEq(category.name, "New Category");
        assertEq(category.description, "A new category");
        assertTrue(category.active);
    }
    
    function test_UpdateCategory() public {
        vm.startPrank(owner);
        vm.expectEmit(false, false, false, true);
        emit CategoryUpdated(0, "Updated DeFi", "Updated description", false);
        registry.updateCategory(0, "Updated DeFi", "Updated description", false);
        vm.stopPrank();
        
        TokenRegistry.CategoryInfo memory category = registry.getCategoryInfo(0);
        assertEq(category.name, "Updated DeFi");
        assertEq(category.description, "Updated description");
        assertFalse(category.active);
    }
    
    function test_WithdrawFees() public {
        // Register a token to generate fees
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
        
        uint256 balanceBefore = user2.balance;
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit FeesWithdrawn(REGISTRATION_FEE, user2);
        registry.withdrawFees(REGISTRATION_FEE, user2);
        vm.stopPrank();
        
        assertEq(user2.balance, balanceBefore + REGISTRATION_FEE);
    }
    
    function test_WithdrawFees_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        registry.withdrawFees(1 ether, user2);
        vm.stopPrank();
    }
    
    function test_WithdrawFees_ZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert(TokenRegistry.InvalidCreatorAddress.selector);
        registry.withdrawFees(1 ether, address(0));
        vm.stopPrank();
    }
    
    // ============ Query Tests ============
    
    function test_GetTokensByCreator() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register multiple tokens
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "Token 1",
            "https://test1.com",
            "https://test1.com/logo.png",
            0,
            tags
        );
        
        // Deploy another token
        vm.stopPrank();
        vm.startPrank(owner);
        URBEToken token2 = new URBEToken(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            user1,
            true,
            true,
            true
        );
        vm.stopPrank();
        
        vm.startPrank(user1);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(token2),
            "Token 2",
            "https://test2.com",
            "https://test2.com/logo.png",
            1,
            tags
        );
        
        vm.stopPrank();
        
        address[] memory tokens = registry.getTokensByCreator(user1);
        assertEq(tokens.length, 2);
        assertEq(tokens[0], address(testToken));
        assertEq(tokens[1], address(token2));
    }
    
    function test_GetTokensByCategory() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register tokens in different categories
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "DeFi Token",
            "https://test1.com",
            "https://test1.com/logo.png",
            0, // DeFi category
            tags
        );
        
        vm.stopPrank();
        vm.startPrank(owner);
        URBEToken token2 = new URBEToken(
            "Gaming Token",
            "GTK",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            user1,
            true,
            true,
            true
        );
        vm.stopPrank();
        
        vm.startPrank(user1);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(token2),
            "Gaming Token",
            "https://test2.com",
            "https://test2.com/logo.png",
            1, // Gaming category
            tags
        );
        
        vm.stopPrank();
        
        address[] memory defiTokens = registry.getTokensByCategory(0);
        assertEq(defiTokens.length, 1);
        assertEq(defiTokens[0], address(testToken));
        
        address[] memory gamingTokens = registry.getTokensByCategory(1);
        assertEq(gamingTokens.length, 1);
        assertEq(gamingTokens[0], address(token2));
    }
    
    function test_GetVerifiedTokens() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
        
        // Initially no verified tokens
        address[] memory verifiedTokens = registry.getVerifiedTokens();
        assertEq(verifiedTokens.length, 0);
        
        // Verify token
        vm.startPrank(owner);
        registry.setTokenVerification(address(testToken), true);
        vm.stopPrank();
        
        // Now should have one verified token
        verifiedTokens = registry.getVerifiedTokens();
        assertEq(verifiedTokens.length, 1);
        assertEq(verifiedTokens[0], address(testToken));
    }
    
    function test_GetVerifiedCreators() public {
        vm.startPrank(user1);
        registry.registerCreator("Test Creator", "A test creator");
        vm.stopPrank();
        
        // Initially no verified creators
        address[] memory verifiedCreators = registry.getVerifiedCreators();
        assertEq(verifiedCreators.length, 0);
        
        // Verify creator
        vm.startPrank(owner);
        registry.setCreatorVerification(user1, true);
        vm.stopPrank();
        
        // Now should have one verified creator
        verifiedCreators = registry.getVerifiedCreators();
        assertEq(verifiedCreators.length, 1);
        assertEq(verifiedCreators[0], user1);
    }
    
    function test_GetStatistics() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register token and creator
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A test token",
            "https://test.com",
            "https://test.com/logo.png",
            0,
            tags
        );
        
        vm.stopPrank();
        
        // Verify token and creator
        vm.startPrank(owner);
        registry.setTokenVerification(address(testToken), true);
        registry.setCreatorVerification(user1, true);
        vm.stopPrank();
        
        (
            uint256 totalTokens,
            uint256 totalCreators,
            uint256 totalCategories,
            uint256 verifiedTokens,
            uint256 verifiedCreators
        ) = registry.getStatistics();
        
        assertEq(totalTokens, 1);
        assertEq(totalCreators, 1);
        assertEq(totalCategories, 5); // Default categories
        assertEq(verifiedTokens, 1);
        assertEq(verifiedCreators, 1);
    }
    
    // ============ Integration Tests ============
    
    function test_CompleteWorkflow() public {
        // 1. Register creator
        vm.startPrank(user1);
        registry.registerCreator("Test Creator", "A test creator");
        vm.stopPrank();
        
        // 2. Register token
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        string[] memory tags = new string[](2);
        tags[0] = "DeFi";
        tags[1] = "Yield";
        
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "A DeFi yield token",
            "https://defi.com",
            "https://defi.com/logo.png",
            0, // DeFi category
            tags
        );
        
        vm.stopPrank();
        
        // 3. Verify token and creator
        vm.startPrank(owner);
        registry.setTokenVerification(address(testToken), true);
        registry.setCreatorVerification(user1, true);
        vm.stopPrank();
        
        // 4. Update token metadata
        vm.startPrank(user1);
        registry.updateTokenMetadata(
            address(testToken),
            "Updated DeFi yield token",
            "https://updated-defi.com",
            "https://updated-defi.com/logo.png"
        );
        
        vm.stopPrank();
        
        // 5. Verify final state
        assertEq(registry.totalTokensRegistered(), 1);
        assertEq(registry.totalCreators(), 1);
        assertTrue(registry.isTokenRegistered(address(testToken)));
        assertTrue(registry.isCreatorRegistered(user1));
        
        TokenRegistry.TokenMetadata memory metadata = registry.getTokenMetadata(address(testToken));
        assertTrue(metadata.verified);
        assertEq(metadata.description, "Updated DeFi yield token");
        
        TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(user1);
        assertTrue(info.verified);
        assertEq(info.totalTokens, 1);
        assertEq(info.verifiedTokens, 1);
    }
    
    // ============ Edge Case Tests ============
    
    function test_ReceiveFunction() public {
        uint256 amount = 1 ether;
        vm.deal(user1, amount);
        
        vm.startPrank(user1);
        (bool success, ) = address(registry).call{value: amount}("");
        assertTrue(success);
        vm.stopPrank();
        
        assertEq(address(registry).balance, amount);
    }
    
    function test_MultipleTokensSameCreator() public {
        vm.startPrank(user1);
        vm.deal(user1, 3 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register multiple tokens
        for (uint256 i = 0; i < 3; i++) {
            vm.stopPrank();
            vm.startPrank(owner);
            URBEToken newToken = new URBEToken(
                string(abi.encodePacked("Token ", i)),
                string(abi.encodePacked("TK", i)),
                INITIAL_SUPPLY,
                MAX_SUPPLY,
                user1,
                true,
                true,
                true
            );
            vm.stopPrank();
            
            vm.startPrank(user1);
            registry.registerToken{value: REGISTRATION_FEE}(
                address(newToken),
                string(abi.encodePacked("Token ", i)),
                string(abi.encodePacked("https://token", i, ".com")),
                string(abi.encodePacked("https://token", i, ".com/logo.png")),
                i % 3, // Different categories
                tags
            );
        }
        
        vm.stopPrank();
        
        // Verify creator stats
        TokenRegistry.CreatorInfo memory info = registry.getCreatorInfo(user1);
        assertEq(info.totalTokens, 3);
        assertEq(info.lastActivity, block.timestamp);
        
        // Verify tokens by creator
        address[] memory tokens = registry.getTokensByCreator(user1);
        assertEq(tokens.length, 3);
    }
    
    function test_CategoryTokenCount() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        string[] memory tags = new string[](1);
        tags[0] = "Test";
        
        // Register tokens in same category
        registry.registerToken{value: REGISTRATION_FEE}(
            address(testToken),
            "Token 1",
            "https://test1.com",
            "https://test1.com/logo.png",
            0, // DeFi category
            tags
        );
        
        vm.stopPrank();
        vm.startPrank(owner);
        URBEToken token2 = new URBEToken(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            user1,
            true,
            true,
            true
        );
        vm.stopPrank();
        
        vm.startPrank(user1);
        registry.registerToken{value: REGISTRATION_FEE}(
            address(token2),
            "Token 2",
            "https://test2.com",
            "https://test2.com/logo.png",
            0, // Same DeFi category
            tags
        );
        
        vm.stopPrank();
        
        // Verify category has 2 tokens
        address[] memory defiTokens = registry.getTokensByCategory(0);
        assertEq(defiTokens.length, 2);
    }
} 
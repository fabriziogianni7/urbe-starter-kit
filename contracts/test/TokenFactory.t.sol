// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {URBEToken} from "../src/URBEToken.sol";

/**
 * @title TokenFactoryTest
 * @dev Comprehensive test suite for TokenFactory contract
 */
contract TokenFactoryTest is Test {
    TokenFactory public factory;
    URBEToken public deployedToken;
    
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);
    
    uint256 public constant DEPLOYMENT_FEE = 0.01 ether;
    uint256 public constant MAX_TOKENS_PER_CREATOR = 10;
    
    // Token parameters
    string public constant TOKEN_NAME = "Test Token";
    string public constant TOKEN_SYMBOL = "TEST";
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1M tokens
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18; // 10M tokens
    
    event TokenDeployed(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        address indexed creator,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    );
    
    event DeploymentFeeUpdated(uint256 oldFee, uint256 newFee, address indexed by);
    event MaxTokensPerCreatorUpdated(uint256 oldMax, uint256 newMax, address indexed by);
    event FactoryPauseToggled(bool paused, address indexed by);
    event FeesWithdrawn(uint256 amount, address indexed to);
    
    function setUp() public {
        vm.startPrank(owner);
        factory = new TokenFactory(owner, DEPLOYMENT_FEE, MAX_TOKENS_PER_CREATOR);
        vm.stopPrank();
    }
    
    // ============ Constructor Tests ============
    
    function test_Constructor_SetsCorrectValues() public {
        assertEq(factory.owner(), owner);
        assertEq(factory.deploymentFee(), DEPLOYMENT_FEE);
        assertEq(factory.maxTokensPerCreator(), MAX_TOKENS_PER_CREATOR);
        assertEq(factory.totalTokensDeployed(), 0);
        assertFalse(factory.factoryPaused());
    }
    
    function test_Constructor_ZeroAddressOwner() public {
        vm.expectRevert(); // OwnableInvalidOwner error from OpenZeppelin
        new TokenFactory(address(0), DEPLOYMENT_FEE, MAX_TOKENS_PER_CREATOR);
    }
    
    // ============ Deployment Tests ============
    
    function test_DeployToken_Success() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        // We can't predict the exact token address, so we'll test the event separately
        
        address tokenAddress = factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        // Verify token deployment
        assertTrue(tokenAddress != address(0));
        assertEq(factory.totalTokensDeployed(), 1);
        assertEq(factory.getTokenCountByCreator(user1), 1);
        
        // Verify token info
        TokenFactory.TokenInfo memory info = factory.getTokenInfo(tokenAddress);
        assertEq(info.tokenAddress, tokenAddress);
        assertEq(info.name, TOKEN_NAME);
        assertEq(info.symbol, TOKEN_SYMBOL);
        assertEq(info.initialSupply, INITIAL_SUPPLY);
        assertEq(info.maxSupply, MAX_SUPPLY);
        assertEq(info.creator, user1);
        assertTrue(info.mintingEnabled);
        assertTrue(info.burningEnabled);
        assertTrue(info.pausingEnabled);
        
        // Verify token functionality
        URBEToken token = URBEToken(tokenAddress);
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.maxSupply(), MAX_SUPPLY);
        assertEq(token.balanceOf(user1), INITIAL_SUPPLY);
    }
    
    function test_DeployTokenWithOwner_Success() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        address tokenAddress = factory.deployTokenWithOwner{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            user2, // Different owner
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        // Verify token owner
        URBEToken token = URBEToken(tokenAddress);
        assertEq(token.owner(), user2);
        assertEq(token.balanceOf(user2), INITIAL_SUPPLY);
        
        // Verify creator tracking
        assertEq(factory.getTokenCountByCreator(user1), 1);
        assertEq(factory.getTokenInfo(tokenAddress).creator, user1);
    }
    
    function test_DeployToken_InsufficientFee() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.InsufficientDeploymentFee.selector);
        factory.deployToken{value: DEPLOYMENT_FEE - 0.001 ether}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_EmptyName() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.EmptyName.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "",
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_EmptySymbol() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.EmptySymbol.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            "",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_ZeroInitialSupply() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.ZeroInitialSupply.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            0,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_ZeroMaxSupply() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.ZeroMaxSupply.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            0,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_InitialSupplyExceedsMax() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.InitialSupplyExceedsMax.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            MAX_SUPPLY + 1,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_ZeroAddressOwner() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.InvalidTokenAddress.selector);
        factory.deployTokenWithOwner{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            address(0),
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_FactoryPaused() public {
        vm.startPrank(owner);
        factory.setFactoryPaused(true);
        vm.stopPrank();
        
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        vm.expectRevert(TokenFactory.FactoryPaused.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    function test_DeployToken_MaxTokensPerCreatorExceeded() public {
        vm.startPrank(user1);
        vm.deal(user1, 10 ether);
        
        // Deploy max tokens
        for (uint256 i = 0; i < MAX_TOKENS_PER_CREATOR; i++) {
            factory.deployToken{value: DEPLOYMENT_FEE}(
                string(abi.encodePacked("Token ", i)),
                string(abi.encodePacked("TK", i)),
                INITIAL_SUPPLY,
                MAX_SUPPLY,
                true,
                true,
                true
            );
        }
        
        // Try to deploy one more
        vm.expectRevert(TokenFactory.MaxTokensPerCreatorExceeded.selector);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "Extra Token",
            "EXTRA",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
    }
    
    // ============ Query Tests ============
    
    function test_GetTokensByCreator() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        // Deploy multiple tokens
        address token1 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 1",
            "TK1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        address token2 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        address[] memory tokens = factory.getTokensByCreator(user1);
        assertEq(tokens.length, 2);
        assertEq(tokens[0], token1);
        assertEq(tokens[1], token2);
    }
    
    function test_GetTokenCountByCreator() public {
        vm.startPrank(user1);
        vm.deal(user1, 3 ether);
        
        assertEq(factory.getTokenCountByCreator(user1), 0);
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 1",
            "TK1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        assertEq(factory.getTokenCountByCreator(user1), 1);
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        assertEq(factory.getTokenCountByCreator(user1), 2);
        
        vm.stopPrank();
    }
    
    function test_GetAllTokens() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        address token1 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 1",
            "TK1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        vm.startPrank(user2);
        vm.deal(user2, 1 ether);
        
        address token2 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        address[] memory allTokens = factory.getAllTokens();
        assertEq(allTokens.length, 2);
        assertEq(allTokens[0], token1);
        assertEq(allTokens[1], token2);
        assertEq(factory.getTotalTokensDeployed(), 2);
    }
    
    function test_IsTokenCreator() public {
        assertFalse(factory.isTokenCreator(user1));
        
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        assertTrue(factory.isTokenCreator(user1));
    }
    
    function test_GetTokensByCreatorPaginated() public {
        vm.startPrank(user1);
        vm.deal(user1, 5 ether);
        
        // Deploy 5 tokens
        for (uint256 i = 0; i < 5; i++) {
            factory.deployToken{value: DEPLOYMENT_FEE}(
                string(abi.encodePacked("Token ", i)),
                string(abi.encodePacked("TK", i)),
                INITIAL_SUPPLY,
                MAX_SUPPLY,
                true,
                true,
                true
            );
        }
        
        vm.stopPrank();
        
        // Test pagination
        (address[] memory tokens, uint256 total) = factory.getTokensByCreatorPaginated(user1, 0, 3);
        assertEq(tokens.length, 3);
        assertEq(total, 5);
        
        (tokens, total) = factory.getTokensByCreatorPaginated(user1, 3, 3);
        assertEq(tokens.length, 2);
        assertEq(total, 5);
        
        (tokens, total) = factory.getTokensByCreatorPaginated(user1, 10, 3);
        assertEq(tokens.length, 0);
        assertEq(total, 5);
    }
    
    function test_GetTokenByCreatorAtIndex() public {
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        address token1 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 1",
            "TK1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        address token2 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        TokenFactory.TokenInfo memory info1 = factory.getTokenByCreatorAtIndex(user1, 0);
        assertEq(info1.tokenAddress, token1);
        assertEq(info1.name, "Token 1");
        
        TokenFactory.TokenInfo memory info2 = factory.getTokenByCreatorAtIndex(user1, 1);
        assertEq(info2.tokenAddress, token2);
        assertEq(info2.name, "Token 2");
        
        vm.expectRevert(TokenFactory.IndexOutOfBounds.selector);
        factory.getTokenByCreatorAtIndex(user1, 2);
    }
    
    // ============ Owner Function Tests ============
    
    function test_SetDeploymentFee() public {
        uint256 newFee = 0.02 ether;
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit DeploymentFeeUpdated(DEPLOYMENT_FEE, newFee, owner);
        factory.setDeploymentFee(newFee);
        vm.stopPrank();
        
        assertEq(factory.deploymentFee(), newFee);
    }
    
    function test_SetDeploymentFee_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        factory.setDeploymentFee(0.02 ether);
        vm.stopPrank();
    }
    
    function test_SetMaxTokensPerCreator() public {
        uint256 newMax = 20;
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit MaxTokensPerCreatorUpdated(MAX_TOKENS_PER_CREATOR, newMax, owner);
        factory.setMaxTokensPerCreator(newMax);
        vm.stopPrank();
        
        assertEq(factory.maxTokensPerCreator(), newMax);
    }
    
    function test_SetMaxTokensPerCreator_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        factory.setMaxTokensPerCreator(20);
        vm.stopPrank();
    }
    
    function test_SetFactoryPaused() public {
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit FactoryPauseToggled(true, owner);
        factory.setFactoryPaused(true);
        vm.stopPrank();
        
        assertTrue(factory.factoryPaused());
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit FactoryPauseToggled(false, owner);
        factory.setFactoryPaused(false);
        vm.stopPrank();
        
        assertFalse(factory.factoryPaused());
    }
    
    function test_SetFactoryPaused_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        factory.setFactoryPaused(true);
        vm.stopPrank();
    }
    
    function test_WithdrawFees() public {
        // Deploy a token to generate fees
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        vm.stopPrank();
        
        uint256 balanceBefore = user2.balance;
        
        vm.startPrank(owner);
        vm.expectEmit(false, false, true, true);
        emit FeesWithdrawn(DEPLOYMENT_FEE, user2);
        factory.withdrawFees(DEPLOYMENT_FEE, user2);
        vm.stopPrank();
        
        assertEq(user2.balance, balanceBefore + DEPLOYMENT_FEE);
    }
    
    function test_WithdrawFees_OnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert();
        factory.withdrawFees(1 ether, user2);
        vm.stopPrank();
    }
    
    function test_WithdrawFees_ZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert(TokenFactory.InvalidTokenAddress.selector);
        factory.withdrawFees(1 ether, address(0));
        vm.stopPrank();
    }
    
    function test_WithdrawFees_InsufficientBalance() public {
        vm.startPrank(owner);
        vm.expectRevert(TokenFactory.InsufficientDeploymentFee.selector);
        factory.withdrawFees(1 ether, user2);
        vm.stopPrank();
    }
    
    // ============ Integration Tests ============
    
    function test_CompleteWorkflow() public {
        // 1. Deploy tokens
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        address token1 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 1",
            "TK1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        address token2 = factory.deployToken{value: DEPLOYMENT_FEE}(
            "Token 2",
            "TK2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            false,
            true,
            false
        );
        
        vm.stopPrank();
        
        // 2. Verify factory state
        assertEq(factory.totalTokensDeployed(), 2);
        assertEq(factory.getTokenCountByCreator(user1), 2);
        assertTrue(factory.isTokenCreator(user1));
        
        // 3. Verify token functionality
        URBEToken token1Contract = URBEToken(token1);
        URBEToken token2Contract = URBEToken(token2);
        
        assertEq(token1Contract.name(), "Token 1");
        assertEq(token2Contract.name(), "Token 2");
        assertTrue(token1Contract.mintingEnabled());
        assertFalse(token2Contract.mintingEnabled());
        
        // 4. Test token operations
        vm.startPrank(user1);
        token1Contract.mint(user2, 1000 * 10**18);
        assertEq(token1Contract.balanceOf(user2), 1000 * 10**18);
        vm.stopPrank();
        
        // 5. Test factory queries
        address[] memory user1Tokens = factory.getTokensByCreator(user1);
        assertEq(user1Tokens.length, 2);
        assertEq(user1Tokens[0], token1);
        assertEq(user1Tokens[1], token2);
        
        address[] memory allTokens = factory.getAllTokens();
        assertEq(allTokens.length, 2);
    }
    
    // ============ Edge Case Tests ============
    
    function test_ReceiveFunction() public {
        uint256 amount = 1 ether;
        vm.deal(user1, amount);
        
        vm.startPrank(user1);
        (bool success, ) = address(factory).call{value: amount}("");
        assertTrue(success);
        vm.stopPrank();
        
        assertEq(address(factory).balance, amount);
    }
    
    function test_MultipleCreators() public {
        // User 1 deploys tokens
        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "User1 Token 1",
            "U1T1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "User1 Token 2",
            "U1T2",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        // User 2 deploys tokens
        vm.startPrank(user2);
        vm.deal(user2, 1 ether);
        
        factory.deployToken{value: DEPLOYMENT_FEE}(
            "User2 Token 1",
            "U2T1",
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            true,
            true
        );
        
        vm.stopPrank();
        
        // Verify counts
        assertEq(factory.getTokenCountByCreator(user1), 2);
        assertEq(factory.getTokenCountByCreator(user2), 1);
        assertEq(factory.totalTokensDeployed(), 3);
        
        // Verify creator status
        assertTrue(factory.isTokenCreator(user1));
        assertTrue(factory.isTokenCreator(user2));
        assertFalse(factory.isTokenCreator(user3));
    }
    
    function test_TokenInfoAccuracy() public {
        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        
        uint256 deploymentTime = block.timestamp;
        
        address tokenAddress = factory.deployToken{value: DEPLOYMENT_FEE}(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            true,
            false,
            true
        );
        
        vm.stopPrank();
        
        TokenFactory.TokenInfo memory info = factory.getTokenInfo(tokenAddress);
        
        assertEq(info.tokenAddress, tokenAddress);
        assertEq(info.name, TOKEN_NAME);
        assertEq(info.symbol, TOKEN_SYMBOL);
        assertEq(info.initialSupply, INITIAL_SUPPLY);
        assertEq(info.maxSupply, MAX_SUPPLY);
        assertEq(info.creator, user1);
        assertEq(info.createdAt, deploymentTime);
        assertTrue(info.mintingEnabled);
        assertFalse(info.burningEnabled);
        assertTrue(info.pausingEnabled);
    }
} 
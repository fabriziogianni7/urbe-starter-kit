// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {URBEToken} from "../src/URBEToken.sol";

/**
 * @title DeployURBEToken
 * @dev Deployment script for URBEToken contract
 */
contract DeployURBEToken is Script {
    // ============ State Variables ============
    
    /// @notice Token configuration
    string public constant TOKEN_NAME = "URBE Token";
    string public constant TOKEN_SYMBOL = "URBE";
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1M tokens
    uint256 public constant MAX_SUPPLY = 10000000 * 10**18; // 10M tokens
    
    // ============ Events ============
    
    event TokenDeployed(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 initialSupply,
        uint256 maxSupply,
        address indexed owner
    );
    
    // ============ Functions ============
    
    /**
     * @notice Deploy URBEToken with default configuration
     * @return token The deployed URBEToken contract
     */
    function run() external returns (URBEToken token) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying URBEToken...");
        console2.log("Deployer:", deployer);
        console2.log("Token Name:", TOKEN_NAME);
        console2.log("Token Symbol:", TOKEN_SYMBOL);
        console2.log("Initial Supply:", INITIAL_SUPPLY);
        console2.log("Max Supply:", MAX_SUPPLY);
        
        vm.startBroadcast(deployerPrivateKey);
        
        token = new URBEToken(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            deployer,
            true,  // minting enabled
            true,  // burning enabled
            true   // pausing enabled
        );
        
        vm.stopBroadcast();
        
        console2.log("URBEToken deployed at:", address(token));
        console2.log("Owner:", deployer);
        console2.log("Initial balance:", token.balanceOf(deployer));
        console2.log("Remaining mintable supply:", token.remainingMintableSupply());
        
        emit TokenDeployed(
            address(token),
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            deployer
        );
    }
    
    /**
     * @notice Deploy URBEToken with custom configuration
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param initialSupply The initial supply of tokens
     * @param maxSupply The maximum supply of tokens
     * @param mintingEnabled Whether minting is initially enabled
     * @param burningEnabled Whether burning is initially enabled
     * @param pausingEnabled Whether pausing is initially enabled
     * @return token The deployed URBEToken contract
     */
    function runCustom(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint256 maxSupply,
        bool mintingEnabled,
        bool burningEnabled,
        bool pausingEnabled
    ) external returns (URBEToken token) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying URBEToken with custom configuration...");
        console2.log("Deployer:", deployer);
        console2.log("Token Name:", name_);
        console2.log("Token Symbol:", symbol_);
        console2.log("Initial Supply:", initialSupply);
        console2.log("Max Supply:", maxSupply);
        console2.log("Minting Enabled:", mintingEnabled);
        console2.log("Burning Enabled:", burningEnabled);
        console2.log("Pausing Enabled:", pausingEnabled);
        
        vm.startBroadcast(deployerPrivateKey);
        
        token = new URBEToken(
            name_,
            symbol_,
            initialSupply,
            maxSupply,
            deployer,
            mintingEnabled,
            burningEnabled,
            pausingEnabled
        );
        
        vm.stopBroadcast();
        
        console2.log("URBEToken deployed at:", address(token));
        console2.log("Owner:", deployer);
        console2.log("Initial balance:", token.balanceOf(deployer));
        console2.log("Remaining mintable supply:", token.remainingMintableSupply());
        
        emit TokenDeployed(
            address(token),
            name_,
            symbol_,
            initialSupply,
            maxSupply,
            deployer
        );
    }
    
    /**
     * @notice Deploy URBEToken for testing (uses default configuration)
     * @return token The deployed URBEToken contract
     */
    function runForTesting() external returns (URBEToken token) {
        address deployer = address(0x1);
        
        console2.log("Deploying URBEToken for testing...");
        console2.log("Deployer:", deployer);
        
        token = new URBEToken(
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            deployer,
            true,  // minting enabled
            true,  // burning enabled
            true   // pausing enabled
        );
        
        console2.log("URBEToken deployed at:", address(token));
        console2.log("Owner:", deployer);
        console2.log("Initial balance:", token.balanceOf(deployer));
        
        emit TokenDeployed(
            address(token),
            TOKEN_NAME,
            TOKEN_SYMBOL,
            INITIAL_SUPPLY,
            MAX_SUPPLY,
            deployer
        );
    }
} 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {TokenFactory} from "../src/TokenFactory.sol";

/**
 * @title DeployTokenFactory
 * @dev Deployment script for TokenFactory contract
 */
contract DeployTokenFactory is Script {
    // ============ State Variables ============
    
    /// @notice Default deployment fee (0.01 ETH)
    uint256 public constant DEFAULT_DEPLOYMENT_FEE = 0.01 ether;
    
    /// @notice Default max tokens per creator
    uint256 public constant DEFAULT_MAX_TOKENS_PER_CREATOR = 10;
    
    // ============ Events ============
    
    event FactoryDeployed(
        address indexed factoryAddress,
        address indexed owner,
        uint256 deploymentFee,
        uint256 maxTokensPerCreator
    );
    
    // ============ Functions ============
    
    /**
     * @notice Deploy TokenFactory with default configuration
     * @return factory The deployed TokenFactory contract
     */
    function run() external returns (TokenFactory factory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying TokenFactory...");
        console2.log("Deployer:", deployer);
        console2.log("Deployment Fee:", DEFAULT_DEPLOYMENT_FEE);
        console2.log("Max Tokens Per Creator:", DEFAULT_MAX_TOKENS_PER_CREATOR);
        
        vm.startBroadcast(deployerPrivateKey);
        
        factory = new TokenFactory(
            deployer,
            DEFAULT_DEPLOYMENT_FEE,
            DEFAULT_MAX_TOKENS_PER_CREATOR
        );
        
        vm.stopBroadcast();
        
        console2.log("TokenFactory deployed at:", address(factory));
        console2.log("Owner:", deployer);
        console2.log("Deployment Fee:", factory.deploymentFee());
        console2.log("Max Tokens Per Creator:", factory.maxTokensPerCreator());
        
        emit FactoryDeployed(
            address(factory),
            deployer,
            DEFAULT_DEPLOYMENT_FEE,
            DEFAULT_MAX_TOKENS_PER_CREATOR
        );
    }
    
    /**
     * @notice Deploy TokenFactory with custom configuration
     * @param deploymentFee The deployment fee in wei
     * @param maxTokensPerCreator The maximum tokens per creator
     * @return factory The deployed TokenFactory contract
     */
    function runCustom(
        uint256 deploymentFee,
        uint256 maxTokensPerCreator
    ) external returns (TokenFactory factory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying TokenFactory with custom configuration...");
        console2.log("Deployer:", deployer);
        console2.log("Deployment Fee:", deploymentFee);
        console2.log("Max Tokens Per Creator:", maxTokensPerCreator);
        
        vm.startBroadcast(deployerPrivateKey);
        
        factory = new TokenFactory(
            deployer,
            deploymentFee,
            maxTokensPerCreator
        );
        
        vm.stopBroadcast();
        
        console2.log("TokenFactory deployed at:", address(factory));
        console2.log("Owner:", deployer);
        console2.log("Deployment Fee:", factory.deploymentFee());
        console2.log("Max Tokens Per Creator:", factory.maxTokensPerCreator());
        
        emit FactoryDeployed(
            address(factory),
            deployer,
            deploymentFee,
            maxTokensPerCreator
        );
    }
    
    /**
     * @notice Deploy TokenFactory for testing (uses default configuration)
     * @return factory The deployed TokenFactory contract
     */
    function runForTesting() external returns (TokenFactory factory) {
        address deployer = address(0x1);
        
        console2.log("Deploying TokenFactory for testing...");
        console2.log("Deployer:", deployer);
        
        factory = new TokenFactory(
            deployer,
            DEFAULT_DEPLOYMENT_FEE,
            DEFAULT_MAX_TOKENS_PER_CREATOR
        );
        
        console2.log("TokenFactory deployed at:", address(factory));
        console2.log("Owner:", deployer);
        
        emit FactoryDeployed(
            address(factory),
            deployer,
            DEFAULT_DEPLOYMENT_FEE,
            DEFAULT_MAX_TOKENS_PER_CREATOR
        );
    }
} 
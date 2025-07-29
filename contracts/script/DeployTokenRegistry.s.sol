// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {TokenRegistry} from "../src/TokenRegistry.sol";
import {TokenFactory} from "../src/TokenFactory.sol";

/**
 * @title DeployTokenRegistry
 * @dev Deployment script for TokenRegistry contract
 */
contract DeployTokenRegistry is Script {
    // ============ State Variables ============
    
    /// @notice Default registration fee (0.01 ETH)
    uint256 public constant DEFAULT_REGISTRATION_FEE = 0.01 ether;
    
    /// @notice Default minimum tokens for verification
    uint256 public constant DEFAULT_MIN_TOKENS_FOR_VERIFICATION = 3;
    
    /// @notice Default minimum volume for verification
    uint256 public constant DEFAULT_MIN_VOLUME_FOR_VERIFICATION = 1000 * 10**18;
    
    // ============ Events ============
    
    event RegistryDeployed(
        address indexed registryAddress,
        address indexed factoryAddress,
        address indexed owner,
        uint256 registrationFee,
        uint256 minTokensForVerification,
        uint256 minVolumeForVerification
    );
    
    // ============ Functions ============
    
    /**
     * @notice Deploy TokenRegistry with default configuration
     * @return registry The deployed TokenRegistry contract
     */
    function run() external returns (TokenRegistry registry) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying TokenRegistry...");
        console2.log("Deployer:", deployer);
        console2.log("Registration Fee:", DEFAULT_REGISTRATION_FEE);
        console2.log("Min Tokens For Verification:", DEFAULT_MIN_TOKENS_FOR_VERIFICATION);
        console2.log("Min Volume For Verification:", DEFAULT_MIN_VOLUME_FOR_VERIFICATION);
        
        // First deploy TokenFactory if not provided
        address factoryAddress = vm.envAddress("TOKEN_FACTORY_ADDRESS");
        if (factoryAddress == address(0)) {
            console2.log("TokenFactory address not provided, deploying new factory...");
            
            vm.startBroadcast(deployerPrivateKey);
            
            TokenFactory factory = new TokenFactory(
                deployer,
                0.01 ether, // deployment fee
                10 // max tokens per creator
            );
            
            factoryAddress = address(factory);
            
            vm.stopBroadcast();
            
            console2.log("TokenFactory deployed at:", factoryAddress);
        } else {
            console2.log("Using existing TokenFactory at:", factoryAddress);
        }
        
        vm.startBroadcast(deployerPrivateKey);
        
        registry = new TokenRegistry(
            deployer,
            DEFAULT_REGISTRATION_FEE,
            factoryAddress,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
        
        vm.stopBroadcast();
        
        console2.log("TokenRegistry deployed at:", address(registry));
        console2.log("Owner:", deployer);
        console2.log("TokenFactory:", factoryAddress);
        console2.log("Registration Fee:", registry.registrationFee());
        console2.log("Total Categories:", registry.totalCategories());
        
        emit RegistryDeployed(
            address(registry),
            factoryAddress,
            deployer,
            DEFAULT_REGISTRATION_FEE,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
    }
    
    /**
     * @notice Deploy TokenRegistry with custom configuration
     * @param registrationFee The registration fee in wei
     * @param minTokensForVerification Minimum tokens for verification
     * @param minVolumeForVerification Minimum volume for verification
     * @return registry The deployed TokenRegistry contract
     */
    function runCustom(
        uint256 registrationFee,
        uint256 minTokensForVerification,
        uint256 minVolumeForVerification
    ) external returns (TokenRegistry registry) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying TokenRegistry with custom configuration...");
        console2.log("Deployer:", deployer);
        console2.log("Registration Fee:", registrationFee);
        console2.log("Min Tokens For Verification:", minTokensForVerification);
        console2.log("Min Volume For Verification:", minVolumeForVerification);
        
        // First deploy TokenFactory if not provided
        address factoryAddress = vm.envAddress("TOKEN_FACTORY_ADDRESS");
        if (factoryAddress == address(0)) {
            console2.log("TokenFactory address not provided, deploying new factory...");
            
            vm.startBroadcast(deployerPrivateKey);
            
            TokenFactory factory = new TokenFactory(
                deployer,
                0.01 ether, // deployment fee
                10 // max tokens per creator
            );
            
            factoryAddress = address(factory);
            
            vm.stopBroadcast();
            
            console2.log("TokenFactory deployed at:", factoryAddress);
        } else {
            console2.log("Using existing TokenFactory at:", factoryAddress);
        }
        
        vm.startBroadcast(deployerPrivateKey);
        
        registry = new TokenRegistry(
            deployer,
            registrationFee,
            factoryAddress,
            minTokensForVerification,
            minVolumeForVerification
        );
        
        vm.stopBroadcast();
        
        console2.log("TokenRegistry deployed at:", address(registry));
        console2.log("Owner:", deployer);
        console2.log("TokenFactory:", factoryAddress);
        console2.log("Registration Fee:", registry.registrationFee());
        console2.log("Total Categories:", registry.totalCategories());
        
        emit RegistryDeployed(
            address(registry),
            factoryAddress,
            deployer,
            registrationFee,
            minTokensForVerification,
            minVolumeForVerification
        );
    }
    
    /**
     * @notice Deploy TokenRegistry with existing TokenFactory
     * @param factoryAddress The address of existing TokenFactory
     * @return registry The deployed TokenRegistry contract
     */
    function runWithFactory(address factoryAddress) external returns (TokenRegistry registry) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying TokenRegistry with existing TokenFactory...");
        console2.log("Deployer:", deployer);
        console2.log("TokenFactory:", factoryAddress);
        console2.log("Registration Fee:", DEFAULT_REGISTRATION_FEE);
        
        vm.startBroadcast(deployerPrivateKey);
        
        registry = new TokenRegistry(
            deployer,
            DEFAULT_REGISTRATION_FEE,
            factoryAddress,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
        
        vm.stopBroadcast();
        
        console2.log("TokenRegistry deployed at:", address(registry));
        console2.log("Owner:", deployer);
        console2.log("TokenFactory:", factoryAddress);
        console2.log("Registration Fee:", registry.registrationFee());
        console2.log("Total Categories:", registry.totalCategories());
        
        emit RegistryDeployed(
            address(registry),
            factoryAddress,
            deployer,
            DEFAULT_REGISTRATION_FEE,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
    }
    
    /**
     * @notice Deploy TokenRegistry for testing (uses default configuration)
     * @return registry The deployed TokenRegistry contract
     */
    function runForTesting() external returns (TokenRegistry registry) {
        address deployer = address(0x1);
        address factoryAddress = address(0x2);
        
        console2.log("Deploying TokenRegistry for testing...");
        console2.log("Deployer:", deployer);
        console2.log("TokenFactory:", factoryAddress);
        
        registry = new TokenRegistry(
            deployer,
            DEFAULT_REGISTRATION_FEE,
            factoryAddress,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
        
        console2.log("TokenRegistry deployed at:", address(registry));
        console2.log("Owner:", deployer);
        
        emit RegistryDeployed(
            address(registry),
            factoryAddress,
            deployer,
            DEFAULT_REGISTRATION_FEE,
            DEFAULT_MIN_TOKENS_FOR_VERIFICATION,
            DEFAULT_MIN_VOLUME_FOR_VERIFICATION
        );
    }
} 
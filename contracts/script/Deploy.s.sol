// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying contracts with address:", deployer);
        console.log("Account balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy SimpleStorage contract
        SimpleStorage simpleStorage = new SimpleStorage(deployer);
        console.log("SimpleStorage deployed at:", address(simpleStorage));

        // Store initial value
        simpleStorage.store(42);
        console.log("Initial value stored:", simpleStorage.retrieve());

        vm.stopBroadcast();

        // Log deployment information
        console.log("=== Deployment Summary ===");
        console.log("Network:", vm.toString(block.chainid));
        console.log("Deployer:", deployer);
        console.log("SimpleStorage:", address(simpleStorage));
        console.log("Initial Value:", simpleStorage.retrieve());
        console.log("Total Stores:", simpleStorage.getTotalStores());
        console.log("Max Value:", simpleStorage.getMaxValue());
    }
} 
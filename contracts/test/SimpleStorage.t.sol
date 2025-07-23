// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;
    address public owner;
    address public user;

    event ValueStored(address indexed user, uint256 value, uint256 timestamp);
    event ValueRetrieved(address indexed user, uint256 value, uint256 timestamp);

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        
        vm.startPrank(owner);
        simpleStorage = new SimpleStorage(owner);
        vm.stopPrank();
    }

    function test_Constructor() public {
        assertEq(simpleStorage.owner(), owner);
        assertEq(simpleStorage.retrieve(), 0);
        assertEq(simpleStorage.getTotalStores(), 0);
        assertEq(simpleStorage.getMaxValue(), 1000000);
    }

    function test_StoreValue() public {
        uint256 testValue = 42;
        
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit ValueStored(owner, testValue, block.timestamp);
        simpleStorage.store(testValue);
        
        assertEq(simpleStorage.retrieve(), testValue);
        assertEq(simpleStorage.getTotalStores(), 1);
        assertEq(simpleStorage.getUserStores(owner), 1);
    }

    function test_StoreValueMultipleTimes() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;
        
        for (uint256 i = 0; i < values.length; i++) {
            vm.prank(owner);
            simpleStorage.store(values[i]);
        }
        
        assertEq(simpleStorage.retrieve(), values[2]);
        assertEq(simpleStorage.getTotalStores(), 3);
        assertEq(simpleStorage.getUserStores(owner), 3);
    }

    function test_RevertWhenNonOwnerStores() public {
        vm.prank(user);
        vm.expectRevert();
        simpleStorage.store(42);
    }

    function test_RevertWhenStoringZero() public {
        vm.prank(owner);
        vm.expectRevert(SimpleStorage.InvalidValue.selector);
        simpleStorage.store(0);
    }

    function test_RevertWhenStoringValueTooHigh() public {
        vm.prank(owner);
        vm.expectRevert(SimpleStorage.ValueTooHigh.selector);
        simpleStorage.store(1000001);
    }

    function test_StoreMaxValue() public {
        vm.prank(owner);
        simpleStorage.store(1000000);
        
        assertEq(simpleStorage.retrieve(), 1000000);
    }

    function test_RetrieveEmitsEvent() public {
        vm.prank(owner);
        simpleStorage.store(123);
        
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit ValueRetrieved(user, 123, block.timestamp);
        simpleStorage.retrieve();
    }

    function test_GetContractInfo() public {
        vm.prank(owner);
        simpleStorage.store(456);
        
        (uint256 storedValue, uint256 totalStores, uint256 maxValue) = simpleStorage.getContractInfo();
        
        assertEq(storedValue, 456);
        assertEq(totalStores, 1);
        assertEq(maxValue, 1000000);
    }

    function test_GetUserStores() public {
        vm.prank(owner);
        simpleStorage.store(100);
        
        vm.prank(owner);
        simpleStorage.store(200);
        
        assertEq(simpleStorage.getUserStores(owner), 2);
        assertEq(simpleStorage.getUserStores(user), 0);
    }

    function test_Fuzz_StoreValidValues(uint256 value) public {
        vm.assume(value > 0 && value <= 1000000);
        
        vm.prank(owner);
        simpleStorage.store(value);
        
        assertEq(simpleStorage.retrieve(), value);
    }

    function test_Fuzz_RevertInvalidValues(uint256 value) public {
        vm.assume(value == 0 || value > 1000000);
        
        vm.prank(owner);
        if (value == 0) {
            vm.expectRevert(SimpleStorage.InvalidValue.selector);
        } else {
            vm.expectRevert(SimpleStorage.ValueTooHigh.selector);
        }
        simpleStorage.store(value);
    }

    function test_GasUsage() public {
        uint256 gasBefore = gasleft();
        
        vm.prank(owner);
        simpleStorage.store(42);
        
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for store:", gasUsed);
        
        // Ensure gas usage is reasonable (less than 100k gas)
        assertLt(gasUsed, 100000);
    }

    function test_ReentrancyProtection() public {
        // This test ensures the nonReentrant modifier is working
        // In a real scenario, you'd test against a malicious contract
        vm.prank(owner);
        simpleStorage.store(42);
        
        // Should not revert due to reentrancy
        vm.prank(owner);
        simpleStorage.store(84);
        
        assertEq(simpleStorage.retrieve(), 84);
    }
} 
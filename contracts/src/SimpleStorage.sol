// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SimpleStorage
 * @dev A simple storage contract for learning Web3 development
 * @notice This contract allows storing and retrieving a single uint256 value
 * @author Web3 Starter Kit
 */
contract SimpleStorage is Ownable, ReentrancyGuard {
    // Events
    event ValueStored(address indexed user, uint256 value, uint256 timestamp);
    event ValueRetrieved(address indexed user, uint256 value, uint256 timestamp);

    // State variables
    uint256 private _storedValue;
    uint256 private _totalStores;
    mapping(address => uint256) private _userStores;

    // Custom errors
    error InvalidValue();
    error ValueTooHigh();

    // Constants
    uint256 public constant MAX_VALUE = 1000000;

    /**
     * @dev Constructor sets the initial owner
     * @param initialOwner The address that will be the initial owner
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Store a new value
     * @param newValue The value to store
     * @notice Only the owner can store values
     * @notice Value must be less than MAX_VALUE
     */
    function store(uint256 newValue) external onlyOwner nonReentrant {
        if (newValue == 0) revert InvalidValue();
        if (newValue > MAX_VALUE) revert ValueTooHigh();

        _storedValue = newValue;
        _totalStores++;
        _userStores[msg.sender]++;

        emit ValueStored(msg.sender, newValue, block.timestamp);
    }

    /**
     * @dev Retrieve the stored value
     * @return The currently stored value
     */
    function retrieve() external returns (uint256) {
        emit ValueRetrieved(msg.sender, _storedValue, block.timestamp);
        return _storedValue;
    }

    /**
     * @dev Get the total number of stores performed
     * @return The total number of stores
     */
    function getTotalStores() external view returns (uint256) {
        return _totalStores;
    }

    /**
     * @dev Get the number of stores performed by a specific user
     * @param user The address of the user
     * @return The number of stores by the user
     */
    function getUserStores(address user) external view returns (uint256) {
        return _userStores[user];
    }

    /**
     * @dev Get the maximum allowed value
     * @return The maximum value that can be stored
     */
    function getMaxValue() external pure returns (uint256) {
        return MAX_VALUE;
    }

    /**
     * @dev Get contract information
     * @return storedValue The currently stored value
     * @return totalStores The total number of stores
     * @return maxValue The maximum allowed value
     */
    function getContractInfo() external view returns (uint256 storedValue, uint256 totalStores, uint256 maxValue) {
        return (_storedValue, _totalStores, MAX_VALUE);
    }
} 
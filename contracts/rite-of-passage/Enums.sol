// SPDX-License-Identifier: MIT 

pragma solidity >0.8.0;

contract Enums {
    enum Mode {
        Work,
        Play,
        Learn,
        Build,
        Being
    }
    
    Mode currentMode;
    
    function get() public view returns (Mode) {
        return currentMode;
    }
    
    function set(Mode _mode) public {
        currentMode = _mode;
    }
    
    function peace() public {
        currentMode = Mode.Being;
    }
}


/**
 * Enums can be defined at a file level, in other contracts or as libraries
 * 
 * Since enum types are not part of the ABI, the signature of "get"
 * will automatically be changed to "get() returns (uint8)"
 * for all matters external to Solidity.
 * 
 * "set" also takes a unit8 as an argument
 * 
 * Enums cannot have more than 256 members (uint8)
 * 
 * Enums are explicitly convertible to and from integer types
 */ 

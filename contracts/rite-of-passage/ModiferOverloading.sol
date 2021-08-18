// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Base {
    address private owner = address(0);
    
    constructor() {
        owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;     
    }
    
    modifier onlyOwner() virtual {
        require(msg.sender == owner);    
        _;
    }
    
    function sayHello() public view virtual onlyOwner returns(string memory) {
        return "Hello, World!";
    }
}

contract Derived is Base {
    address[] private owners = [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2];

    modifier onlyOwner() override {
        bool ownerFound = false;
        for(uint i=0; i<owners.length; i++) {
            if (owners[i] == msg.sender) {
                ownerFound = true;
                break;
            }
        }
        require(ownerFound);
        _;
    }
}


/**
 [call] from: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4to: Derived.sayHello()data: 0xef5...fb05b
 decoded output	{ "0": "string: Hello, World!" } Copy value to clipboard
 
 [call] from: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2to: Derived.sayHello()data: 0xef5...fb05b
 decoded output	{ "0": "string: Hello, World!" } Copy value to clipboard
 */ 
 
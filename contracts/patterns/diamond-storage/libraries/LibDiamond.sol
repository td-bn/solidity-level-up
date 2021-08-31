// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

library LibDiamond {
    bytes32 constant LOCATION = keccak256("diamond.learn.storage");
    
    struct DiamondStorage {
        mapping(bytes4 => address) selectorToAddress;
        string topSecret;
    }
    
    function diamondStorage() internal pure returns(DiamondStorage storage ds) {
        bytes32 position = LOCATION;
        
        assembly {
            ds.slot := position
        }
    }
}

// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

struct AppStorage {
    mapping(bytes4 => address) selectorToAddress;
    string topSecret;
    uint code;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
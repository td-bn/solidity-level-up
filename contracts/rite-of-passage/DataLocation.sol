// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataLocations {
    uint[] public arr; // storage by default

    function calling(uint[] memory _arr) public {
        arr = _arr; // Independent copy
        uint[] storage storageArr = arr; // Reference
        _arr = storageArr; // Valid and Independent copy
    }
    
    function paging(uint[] calldata _arr) public {
        arr = _arr; // Independent copy
        
        // _arr = arrayy; 
        // Invalid - ref is not convertible to calldata
    }
}
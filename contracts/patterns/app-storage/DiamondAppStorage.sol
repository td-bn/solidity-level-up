// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "./libraries/Storage.sol";
import "./facets/TestFacetAppStorage.sol";

contract DiamondAppStorage {
    AppStorage internal s;
    
    constructor(address facetAddress) {
        s.selectorToAddress[TestFacetAppStorage.getTopSecret.selector] = facetAddress;
        s.selectorToAddress[TestFacetAppStorage.setTopSecret.selector] = facetAddress;
    }

    fallback() external payable {
        address facet = s.selectorToAddress[msg.sig];
        require(facet != address(0), "Diamond: Function does not exist");

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
             // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}
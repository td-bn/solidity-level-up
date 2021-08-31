// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "./libraries/LibDiamond.sol";
import "./facets/TestFacet.sol";

contract DiamondStorage {
    
    constructor(address facetAddress) {
        LibDiamond.DiamondStorage storage diamondStorage = LibDiamond.diamondStorage();

        diamondStorage.selectorToAddress[TestFacet.getTopSecret.selector] = facetAddress;
        diamondStorage.selectorToAddress[TestFacet.setTopSecret.selector] = facetAddress;
    }

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.LOCATION;

        assembly {
            ds.slot := position
        }

        // get facet from function selector
        address facet = ds.selectorToAddress[msg.sig];
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
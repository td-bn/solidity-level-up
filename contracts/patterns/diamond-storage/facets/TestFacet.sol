// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract TestFacet {
    event SetSecret(string secret);
    event GetSecret(string secret);

    function getTopSecret() external returns (string memory) {
        LibDiamond.DiamondStorage storage diamondStorage = LibDiamond.diamondStorage();
        emit GetSecret(diamondStorage.topSecret);
        return diamondStorage.topSecret;
    }
    
    function setTopSecret(string memory secret) external {
        LibDiamond.DiamondStorage storage diamondStorage = LibDiamond.diamondStorage();
        diamondStorage.topSecret = secret;
        emit SetSecret(secret);
    }
}
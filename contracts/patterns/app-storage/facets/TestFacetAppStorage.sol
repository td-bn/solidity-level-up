// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "../libraries/Storage.sol";

contract TestFacetAppStorage {
    AppStorage internal s;

    event SetSecret(string secret);

    function getTopSecret() external view returns (string memory) {
        return s.topSecret;
    }
    
    function setTopSecret(string memory secret) external {
        s.topSecret = secret;
        emit SetSecret(secret);
    }
}
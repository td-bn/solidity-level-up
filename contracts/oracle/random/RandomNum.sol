//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNum is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    bytes32 public requestId;
    
/**
* @dev NETWORK: KOVAN
* @dev   Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
* @dev   LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
* @dev   Key Hash:   0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
* @dev   Fee:        0.1 LINK (100000000000000000)
*/
     
    address LINK_ADDRESS = 0xa36085F69e2889c224210F603D836748e7dC0088;
    address COORDINATOR = 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9;
    
    constructor() VRFConsumerBase(COORDINATOR, LINK_ADDRESS) {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18;
    }
    
    // Request randomness
    function getRandomNum() public returns(bytes32) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        requestId = requestRandomness(keyHash, fee);
        return requestId;
    }
    
    // Callback function used by VRF Coordinator
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
    
    function randomNumber(uint256 random) public returns (uint256) {
        return randomResult;
    }
    
}
// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.7;

/**
 * @dev         A simple contract to illustrate the withdrawl pattern and why it is better
 *              The contract is a version of the 'The king of Ether'
 *              
 *              If you are no longer the richest, you receive the funds of the person 
 *              who is now the richest.
 *
 * @author      td-bn
 */
contract BecomeRichestWithdrawl {
    
    address public richest;
    uint public maxAmount;
    
    mapping(address => uint) pending;
    
    constructor() payable {
        richest = msg.sender;
        maxAmount = msg.value;
    }
    
    function becomeRichest() payable public {
        require(msg.value > maxAmount, "Not enough Ether");
        
        pending[richest] = msg.value;
        
        richest = msg.sender;
        maxAmount = msg.value;
    }
    
    function withdraw() public {
        uint amount = pending[msg.sender];
        
        // Flag to take care of re-entrancy
        pending[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}


/**
 * @dev         A simple contract to illustrate the withdrawl pattern and why it is better
 *              The contract is a version of the 'The king of Ether'
 *              
 *              Same contract as before except that we are making a transfer instead of the 
 *              former richest requesting a withdrawl. 
 *
 * @author      td-bn
 */
contract BecomeRichestTransfer {
    
    address public richest;
    uint public maxAmount;
    
    mapping(address => uint) pending;
    
    constructor() payable {
        richest = msg.sender;
        maxAmount = msg.value;
    }
    
    function becomeRichest() payable public {
        require(msg.value > maxAmount, "Not enough Ether");
        
        payable(richest).transfer(msg.value);
        richest = msg.sender;
        maxAmount = msg.value;
    }
}
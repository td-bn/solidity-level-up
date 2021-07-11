// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
* @title Multi Signature Wallet Contract
* @author td-bn
* @dev Implements a basic multi sig wallet
*/ 
contract MultiSigWallet {
    
    address[] public owners;
    uint public numConfirmations;

    struct Transaction {
        address to;
        uint value;
        uint confirmationCount;
        bool executed;
    }
    
    Transaction[] public transactions;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) confirmations;
    
    // Events
    event Deposit(address from, uint value, uint balance);
    event Submit(address to, address owner, uint value, uint txIndex);
    event Confirm(address owner, uint txIndex);
    event Revoke(address owner, uint txIndex);
    event Execute(address owner, uint txIndex);
    
    // Modifiers
    modifier onlyOwner() {
        require(isOwner[msg.sender], "only owners can trigger this action");
        _;
    }
    
    modifier validTransaction(uint txIndex) {
        require(txIndex < transactions.length, "index not valid");
        _;
    }
    
    modifier notExectued(uint txIndex) {
        require(!transactions[txIndex].executed, "transaction already executed");
        _;
    }
    
    // Constructor
    constructor(address[] memory _owners, uint _numConfirmations) {
        require(_owners.length > 0, "wallet cannot be ownerless");
        require(_owners.length >= numConfirmations, "number of confirmations cannot be greater than number of owners");

        numConfirmations = _numConfirmations;
        
        for (uint i=0; i<_owners.length; i++) {
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
    }
    
    // Receive ether function
    receive() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
    * @dev creates a new transaction that can be confirmed by other owners
    *      creating a transaction by one of the owners automatically means
    *      that the cretor has signed it
    * 
    * @param _to: the address to transfer to
    * @param _value: the amount to transfer
    */
    function submitTx(address _to, uint _value) public onlyOwner{
        require(_to != address(0), "invalid address");
        require(_value <= address(this).balance, "not enough funds in contract");
         
        uint txIndex = transactions.length;
         
        transactions.push(Transaction({
            to: _to,
            value: _value,
            confirmationCount: 1,
            executed: false
        }));
     
        emit Submit(_to, msg.sender, _value, txIndex);
    }
     
    /**
    * @dev confirms transaction at index for given owner if not previously confirmed
    * @param txIndex: the index of the transaction in the array
    */ 
    function confirmTx(uint txIndex) public onlyOwner validTransaction(txIndex) {
        require(!confirmations[txIndex][msg.sender], "you have already confirmed");
        
        Transaction storage transaction = transactions[txIndex];
        confirmations[txIndex][msg.sender] = true;
        transaction.confirmationCount += 1;
         
        emit Confirm(msg.sender, txIndex);
     }
     
    /**
    * @dev revokes confirmation for a transaction at index for given owner iff previously confirmed
    * @param txIndex: the index of the transaction in the array
    */ 
    function revokeConfirmation(uint txIndex) public onlyOwner validTransaction(txIndex) {
        require(confirmations[txIndex][msg.sender], "you haven't confirmed this transaction");
         
        Transaction storage transaction = transactions[txIndex];
        confirmations[txIndex][msg.sender] = false;
        transaction.confirmationCount -= 1;
        
        emit Revoke(msg.sender, txIndex);
    }

    /**
    * @dev executes a transaction if it has the required number of confirmations
    * @param txIndex: the index of the transaction in the array
    */ 
    function execute(uint txIndex) public onlyOwner validTransaction(txIndex) notExectued(txIndex){
        Transaction storage transaction = transactions[txIndex];
        
        require(transaction.confirmationCount >= numConfirmations, "not enough confirmations");
        
        transaction.executed = true;
        
        (bool success, ) = transaction.to.call{value: transaction.value}("");
        require(success, "transaction failed");
        
        emit Execute(msg.sender, txIndex);
    }

    /**
    * @dev returns the owners of the wallet
    */
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
}
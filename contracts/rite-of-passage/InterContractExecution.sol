// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;

contract Store {
    
    uint public num;
    address public setter;
    
    function setNum(uint _num) public returns(uint) {
        num = _num;
        setter = msg.sender;
        
        return num;
    }
}


contract StoreAndSet {
    uint public num;
    address public setter;
    
    function setStoreNum(address _store, uint _num) public returns(uint) {
        (bool success, bytes memory data) = _store.call(abi.encodeWithSignature("setNum(uint256)", _num));
        require(success);
        
        uint setValue;
        assembly {
            setValue := mload(add(add(data, 0x20), 0))
        }
        
        return setValue;
    }
    
    function delegateStoreNum(address _store, uint _num) public returns(uint) {
        (bool success, bytes memory data) = _store.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
        require(success);
        
        uint setValue;
        assembly {
            setValue := mload(add(add(data, 0x20), 0))
        }
        
        return setValue;
    }
}


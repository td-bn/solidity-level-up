// SPDX-License-Identifier: MIT 

pragma solidity >0.8.0;

contract Thrower {
    uint val;
    
    error Invalid(uint);
    
    constructor (uint _val) {
        require(_val != 0, "val cannot be 0");
        assert(_val != 1);
        val = _val;
    }
    
    function setVal(uint _val) external {
        val = _val;
    }
    
    function getBigVal() external view returns(uint) {
        if (val == 42) {
            revert Invalid(val);
        }
        require(val > 100, "val not big enough");

        return val;
    }
}

contract Catcher {
    event Log(string message);
    event Log(uint message);
    event LogBytes(bytes message);
    
    
    Thrower public thrower;
    
    constructor(uint _val) {
        // For external calls
        thrower = new Thrower(_val);
    }

    function setVal(uint _val) external {
        thrower.setVal(_val);
    }
    
    function tryExternal() public {
        try thrower.getBigVal() returns (uint v) {
            emit Log(v);
        } catch Error(string memory reason) {
            emit Log(reason);
        }
    }
}
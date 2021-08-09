// SPDX-License-Identifier: MIT

pragma solidity >0.8.0;

contract Receiver {
    string greeting = "Hello";
    
    event Greeting(string greeting);
    
    function greet() external  {
        emit Greeting(greeting);
    }
}

contract Sender {
    string greeting = "Hi";
    
    function delegatedGreeting(address _contract) external {
        (bool success,) = _contract.delegatecall(
            abi.encodeWithSignature("greet()")
        );
    }

    function callGreeting(address _contract) external {
        (bool success,) = _contract.call(
            abi.encodeWithSignature("greet()")
        );
    }
}

/**
    Greeting event after call() from Sender to Receiver.greet:
    {
       "event": "Greeting",
        "args": {
            "0": "Hello",
            "greeting": "Hello"
        }
    }

    Greeting event after delegatecall() from Sender to Receiver.greet:
    {
        "event": "Greeting",
        "args": {
            "0": "Hi",
            "greeting": "Hi"
        }
    }
*/

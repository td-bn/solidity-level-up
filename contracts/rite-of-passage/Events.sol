// SPDX-License-Identifier: MIT 

pragma solidity >=0.8.7;

contract Activities {
    
    event Brush(string name, uint time);
    event Lunch(string name, uint time, string indexed meal);
    event Play(string name, uint time, string indexed sport);
    
    function morning(string calldata _name, uint time) external {
        emit Brush(_name, time);
    }
    
    function eat(string calldata _name, uint time, string calldata meal) external {
        emit Lunch(_name, time, meal);
    }
    
    function evening(string calldata _name, uint time, string calldata sport) external {
        emit Play(_name, time, sport);
    }
}

contract Person {
    
    Activities activities = new Activities();

    function aDayInTheLife(string calldata _name) public {
        bool earlyRiser = block.basefee % 2 == 0;
        
        if (earlyRiser) {
            activities.morning(_name, 1000);
            activities.eat(_name, 1300, "Sandwich");
            activities.evening(_name, 1800, "Basketball");
        } else {
            activities.morning(_name, 1100);
            activities.eat(_name, 1400, "Chole Bhature");
            activities.evening(_name, 1900, "Football");
        }        
    }
}
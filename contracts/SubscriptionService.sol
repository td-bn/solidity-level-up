// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev A simple subscription service contract
 *      Lets merchants create plans
 *      Lets users susbcribe to those plans
 * @author td-bn
 */
contract SubscriptionService {
    
    uint public planIndex;
    struct Plan {
        address token;
        address merchant;
        uint256 frequency;
        uint256 cost;
    }
    mapping(uint256 => Plan) public plans;
    

    struct Subscription {
        address user;
        uint256 startTime;
        uint256 nextPaymentTime;
    }
    mapping(address => mapping(uint256 => Subscription)) public subscriptions;


    event Transfer(address user, uint256 planId);
    event NewSubscriber(address user, uint256 planId, uint256 time);
    event Cancel(address user, uint256 planId);
    
    /**
     * @dev Function to create a plan that takes
     * @param _token: ERC20 token that the plan expects payment in
     * @param _frequency: how frequently user will be charged
     * @param _cost: how much it will cost per frequency
     */
    function createPlan(address _token, uint256 _frequency, uint256 _cost) external {
        require(_token != address(0), "invalid ERC token");
        require(_frequency > 0, "frequency needs to be positive");
        require(_cost > 0, "cost needs to be positive");
        
        plans[planIndex] = Plan(
            _token,
            msg.sender,
            _frequency,
            _cost
        );
        planIndex++;
    }

    /**
     * @dev Subscribes the sender to the plan specified by _planId
     * @param _planId, id of the plan to subscribe the user to
     */
    function subscribe(uint256 _planId) external {
        Plan memory plan = plans[_planId];
        require(plan.merchant != address(0), "no such plan exists");
        
        IERC20 token = IERC20(plan.token);
        token.transferFrom(msg.sender, plan.merchant, plan.cost);
        emit Transfer(msg.sender, _planId);

        subscriptions[msg.sender][_planId] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + plan.frequency
        );
        
        emit NewSubscriber(msg.sender, _planId, block.timestamp);
    }
    
    /**
     * @dev Cancels the subscription to a plan for the sender
     * @param _planId, id of the plan that the user wants to cancel 
     */
    function cancel(uint256 _planId) external {
        Subscription storage subscription = subscriptions[msg.sender][_planId];
        
        require(subscription.user != address(0), "invalid subscription");
        
        delete subscriptions[msg.sender][_planId];
        emit Cancel(msg.sender, _planId);
    }
    
    /**
     * @dev the merchant the cost of one frequency of the plan
     * @param _subscriber: the susbcriber of the plan in this case
     * @param _planId: the plan the subscriber has to pay for
     */
    function pay(address _subscriber, uint256 _planId) external {
        Subscription storage subscription = subscriptions[_subscriber][_planId];
        require(subscription.user != address(0), "can't process payment for invalid subscription");
        require(block.timestamp > subscription.nextPaymentTime, "payment not due yet");
        
        Plan memory plan = plans[_planId];
        IERC20 token = IERC20(plan.token);
        
        token.transferFrom(_subscriber, plan.merchant, plan.cost);
        
        emit Transfer(_subscriber, _planId);
        subscription.nextPaymentTime = subscription.nextPaymentTime + plan.frequency;
    }
}
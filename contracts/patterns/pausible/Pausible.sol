// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Pausible {
    event Paused(address account);
    event Unpaused(address account);

    bool _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view returns(bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Contract is not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Test is Pausible {

    address owner;

    event Deposit();
    event Withdraw();

    modifier onlyOwner {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function deposit() public payable whenNotPaused {
        emit Deposit();
    }

    function withdraw() public whenNotPaused {
        emit Withdraw();
    }
}
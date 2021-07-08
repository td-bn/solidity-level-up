// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/** 
 * @title Ballot for voting
 * @author td-bn
 * @dev Implements voting with delegation
 */
contract Ballot {
    
    struct Voter {
        uint weight; // weight accumulated from being delegated voltes
        address delegate; // address to delegate vote to
        bool voted; // has voted?
        uint vote; // the proposal that voter voted for
        bool allowed; // allow user to vote if allowed
    }
    
    struct Proposal {
        bytes32 name; // name of the Proposal
        uint voteCount; // number of votes the Proposal has gathered
    }
    
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    modifier hasNotVoted(address voter) {
        require(!voters[voter].voted, "voter has already voted");
        _;
    }
    
    modifier isRegistered(address voter) {
        if (!voters[voter].allowed) {
            voters[voter].allowed = true;
            voters[voter].weight = 1;
        }
        _;
    }
    
    /**
     * @dev creates a set of proposals that voters can vote on
     * @param proposalNames a list of proposal names
     */
    constructor(bytes32[] memory proposalNames) {
        for (uint i=0; i<proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    /**
     * @dev lets voter delegate his vote to some other address
     * @param to the address to delegate the vote to
     */
    function delegate(address to) public isRegistered(msg.sender) isRegistered(to) hasNotVoted(msg.sender) {
        // Get last node in delegation chain
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found delegation loop!");
        }

        // At this point, to has the right delegation address
        Voter storage sender = voters[msg.sender];
        Voter storage delegete = voters[to];
        sender.delegate = to;
        sender.voted = true;
        
        if (delegete.voted) {
            proposals[delegete.vote].voteCount += sender.weight;
        } else {
            delegete.weight += sender.weight;
        }
    }
    
    /**
     * @dev lets voter vote for a given proposal
     * @param proposalId the id of the proposal
     */ 
    function vote(uint proposalId) public isRegistered(msg.sender) hasNotVoted(msg.sender) {
        Voter storage sender = voters[msg.sender];
        sender.voted = true;
        sender.vote = proposalId;
        
        proposals[proposalId].voteCount += sender.weight;
    }
    
    /**
     * @dev finds the winning proposal and returns its name
     * @return winnerName the name of the winning proposal
     */ 
    function winningProposal() public view returns (bytes32 winnerName) {
        uint maxVoteCount=proposals[0].voteCount;
        winnerName = proposals[0].name;
        
        for (uint i=1; i<proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
                winnerName = proposals[i].name;
            }
        }
    }
}
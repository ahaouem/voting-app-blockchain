// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

error Voting__InvalidChoiceIndex(uint256 choiceIndex);
error Voting__InvalidState();
error Voting__InvalidVoter();
error Voting__AlreadyVoted();
error Voting__NotOwner();

contract Voting {
    struct Voter {
        address candidateAddress;
        string name;
        uint256 choiceIndex;
        uint256 voteCount;
    }

    struct Vote {
        address voterAddress;
        uint256 choiceIndex;
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }
    enum State {
        Created,
        Voting,
        Ended
    }

    address public owner;
    string public votingName;
    uint256 public votingStart;
    uint256 public votingEnd;
    State public state;
    address[] public voters;

    mapping(address => Voter) public voterInfo;
    mapping(address => bool) public hasVoted;
    mapping(uint256 => Candidate) public candidates;

    function vote(uint256 _choiceIndex) public {
        if (state != State.Voting) {
            revert Voting__InvalidState();
        }
        if (voterInfo[msg.sender].candidateAddress == address(0)) {
            revert Voting__InvalidVoter();
        }
        if (hasVoted[msg.sender]) {
            revert Voting__AlreadyVoted();
        }
        if (_choiceIndex >= voters.length) {
            revert Voting__InvalidChoiceIndex(_choiceIndex);
        }

        voterInfo[msg.sender].choiceIndex = _choiceIndex;
        voterInfo[msg.sender].voteCount += 1;
        candidates[_choiceIndex].voteCount += 1;
        hasVoted[msg.sender] = true;
    }
}

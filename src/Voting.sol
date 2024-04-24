// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

error Voting__InvalidChoiceIndex(uint256 choiceIndex);
error Voting__InvalidState();
error Voting__InvalidVoter();
error Voting__AlreadyVoted();
error Voting__NotOwner();
error Voting__DisabledForOwner();

contract Voting {
    address public owner;
    uint256 public votingStartTime;
    uint256 public votingEndTime;
    string[2] public choices;
    bool public isPrivate;
    string public category;
    string public description;
    string public title;
    string public image;

    uint256 public votesCount = 0;

    constructor(
        uint256 _votingEndTime,
        string[2] memory _choices,
        bool _isPrivate,
        string memory _category,
        string memory _description,
        string memory _title,
        string memory _image
    ) {
        owner = msg.sender;
        votingStartTime = block.timestamp;
        votingEndTime = _votingEndTime;
        choices = _choices;
        isPrivate = _isPrivate;
        category = _category;
        description = _description;
        title = _title;
        image = _image;
    }

    struct Voter {
        address voterAddress;
        bool hasVoted;
        uint256 choiceIndex;
        uint256 voteTime;
    }

    mapping(address => Voter) public voters;

    enum State {
        Started,
        Ended
    }

    State public state = State.Started;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Voting__NotOwner();
        }
        _;
    }

    modifier notOwner() {
        if (msg.sender == owner) {
            revert Voting__DisabledForOwner();
        }
        _;
    }

    modifier votingTime() {
        if (block.timestamp < votingStartTime || block.timestamp > votingEndTime) {
            revert Voting__InvalidState();
        }
        _;
    }

    function vote(uint256 choiceIndex) public notOwner votingTime {
        if (state == State.Ended) {
            revert Voting__InvalidState();
        }

        if (voters[msg.sender].hasVoted) {
            revert Voting__AlreadyVoted();
        }

        if (choiceIndex >= choices.length) {
            revert Voting__InvalidChoiceIndex(choiceIndex);
        }

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].choiceIndex = choiceIndex;
        voters[msg.sender].voteTime = block.timestamp;
        votesCount++;
    }

    function endVoting() public onlyOwner {
        state = State.Ended;
    }

    function removeVoter(address voterAddress) public onlyOwner votingTime {
        delete voters[voterAddress];
    }

    function removeVote(address voterAddress) public notOwner votingTime {
        if (voters[voterAddress].voterAddress == address(0)) {
            revert Voting__InvalidVoter();
        }

        delete voters[voterAddress];
        votesCount--;
    }

    function getChoices() public view returns (string[2] memory) {
        return choices;
    }

    function getState() public view returns (State) {
        return state;
    }

    function getVoter(address voterAddress) public view returns (Voter memory) {
        return voters[voterAddress];
    }
}

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
    string[] public choices;
    bool public isPrivate;
    string public category;
    string public description;
    string public title;
    string public image;

    uint256 public votesCount = 0;

    constructor(
        uint256 _votingEndTime,
        string[] memory _choices,
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

    function vote(uint256 choiceIndex) public notOwner {
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

    function removeVoter(address voterAddress) public onlyOwner {
        delete voters[voterAddress];
    }

    function removeVote(address voterAddress) public notOwner {
        if (voters[voterAddress].voterAddress == address(0)) {
            revert Voting__InvalidVoter();
        }

        delete voters[voterAddress];
        votesCount--;
    }

    function getChoices() public view returns (string[] memory) {
        return choices;
    }
}

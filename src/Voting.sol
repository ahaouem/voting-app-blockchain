// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

error Voting__InvalidChoiceIndex(uint256 choiceIndex);
error Voting__InvalidState();
error Voting__InvalidVoter();
error Voting__AlreadyVoted();
error Voting__NotOwner();
error Voting__DisabledForOwner();
error Voting__UserHasNotVoted(address voterAddress);
error Voting__UserNotAllowedToVote(address voterAddress);

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

    address[] public allowedVoters;

    uint256 public votesCount = 0;

    constructor(
        uint256 _votingEndTime,
        string[2] memory _choices,
        bool _isPrivate,
        string memory _category,
        string memory _description,
        string memory _title,
        string memory _image,
        address[] memory _allowedVoters
    ) {
        owner = msg.sender;
        votingStartTime = block.timestamp;
        votingEndTime = block.timestamp + _votingEndTime;
        choices = _choices;
        isPrivate = _isPrivate;
        category = _category;
        description = _description;
        title = _title;
        image = _image;
        allowedVoters = _allowedVoters;
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
        if (votingStartTime > votingEndTime) {
            revert Voting__InvalidState();
        }
        _;
    }

    modifier userHasVoted() {
        if (voters[msg.sender].hasVoted) {
            revert Voting__UserHasNotVoted(msg.sender);
        }
        _;
    }

    modifier invalidChoiceIndex() {
        if (voters[msg.sender].choiceIndex >= choices.length) {
            revert Voting__InvalidChoiceIndex(voters[msg.sender].choiceIndex);
        }
        _;
    }

    modifier notAllowedVoter() {
        if (isPrivate) {
            bool isAllowedVoter = false;
            for (
                uint256 userIndex = 0;
                userIndex < allowedVoters.length;
                userIndex++
            ) {
                if (allowedVoters[userIndex] == msg.sender) {
                    isAllowedVoter = true;
                    break;
                }
            }

            if (!isAllowedVoter) {
                revert Voting__UserNotAllowedToVote(msg.sender);
            }
        }
        _;
    }

    function vote(
        uint256 choiceIndex
    )
        public
        notOwner
        userHasVoted
        votingTime
        invalidChoiceIndex
        notAllowedVoter
    {
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

    function getOwner() public view returns (address) {
        return owner;
    }

    function getAllowedVoters() public view returns (address[] memory) {
        return allowedVoters;
    }
}

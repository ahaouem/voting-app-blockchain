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

/// @title Voting Smart Contract for Cloak Voting App
/// @author Olivier Kobialka @OlivierKobialka 2024
contract Voting {
    address public immutable i_owner;
    uint256 public immutable i_votingStartTime;
    bool public immutable i_isPrivate;

    uint256 public votingEndTime;
    string[2] public choices;
    string public category;
    string public description;
    string public title;
    string public image;
    address[] public allowedVoters;
    uint256 public votesCount = 0;

    event VotingStarted(
        uint256 indexed i_votingStartTime,
        uint256 indexed votingEndTime,
        string[2] choices
    );
    event VotingEnded(
        uint256 indexed votingEndTime,
        uint256 indexed votesCount
    );
    event Vote(
        address indexed voterAddress,
        uint256 indexed choiceIndex,
        uint256 indexed voteTime
    );
    event VoteRemoved(
        address indexed voterAddress,
        uint256 indexed voteTime,
        uint256 indexed votesCount
    );

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
        i_owner = msg.sender;
        i_votingStartTime = block.timestamp;
        votingEndTime = block.timestamp + _votingEndTime;
        choices = _choices;
        i_isPrivate = _isPrivate;
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

    /**
     * @dev The voters of the voting.
     */
    mapping(address => Voter) public voters;

    enum State {
        Started,
        Ended
    }

    State public state = State.Started;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Voting__NotOwner();
        }
        _;
    }

    /**
     * @dev Throws if called by the owner.
     */
    modifier notOwner() {
        if (msg.sender == i_owner) {
            revert Voting__DisabledForOwner();
        }
        _;
    }

    /**
     * @dev Throws if the voting is not in progress.
     */
    modifier votingTime() {
        if (i_votingStartTime > votingEndTime) {
            revert Voting__InvalidState();
        }
        _;
    }

    /**
     * @dev Throws if the user has already voted.
     */
    modifier userHasVoted() {
        if (voters[msg.sender].hasVoted) {
            revert Voting__UserHasNotVoted(msg.sender);
        }
        _;
    }

    /**
     * @dev Throws if the choice index is invalid.
     */
    modifier invalidChoiceIndex() {
        if (voters[msg.sender].choiceIndex >= choices.length) {
            revert Voting__InvalidChoiceIndex(voters[msg.sender].choiceIndex);
        }
        _;
    }

    /**
     * @dev Throws if the user is not allowed to vote.
     */
    modifier notAllowedVoter() {
        if (i_isPrivate) {
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

    modifier validVoter(address voterAddress) {
        if (voters[voterAddress].voterAddress == address(0)) {
            revert Voting__InvalidVoter();
        }
        _;
    }

    /**
     * @param choiceIndex The index of the choice to vote for.
     * @dev Allows a user to vote for a choice.
     */
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
        emit Vote(msg.sender, choiceIndex, block.timestamp);

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].choiceIndex = choiceIndex;
        voters[msg.sender].voteTime = block.timestamp;
        votesCount++;
    }

    /**
     * @dev Ends the voting process.
     * @dev Only the owner can call this function.
     */
    function endVoting() public onlyOwner {
        state = State.Ended;
        emit VotingEnded(votingEndTime, votesCount);
    }

    /**
     * @param voterAddress The address of the voter to remove the vote from.
     * @dev Removes the vote of a voter, if the voter has voted.
     */
    function removeVote(
        address voterAddress
    ) public notOwner votingTime validVoter {
        delete voters[voterAddress];
        votesCount--;

        emit VoteRemoved(voterAddress, block.timestamp, votesCount);
    }

    /**
     * @return The choices of the voting.
     */
    function getChoices() public view returns (string[2] memory) {
        return choices;
    }

    /**
     * @return The state of the voting.
     */
    function getState() public view returns (State) {
        return state;
    }

    /**
     * @param voterAddress The address of the voter to get the information from.
     * @return The voter information of the caller.
     */
    function getVoter(address voterAddress) public view returns (Voter memory) {
        return voters[voterAddress];
    }

    /**
     * @return The owner of the voting.
     */
    function getOwner() public view returns (address) {
        return i_owner;
    }

    /**
     * @return The allow list of voters.
     */
    function getAllowedVoters() public view returns (address[] memory) {
        return allowedVoters;
    }

    /**
     * @param choiceIndex The index of the choice to get the vote count from.
     * @return The number of votes for a choice.
     */
    function getOptionVoteCount(
        uint256 choiceIndex
    ) public view returns (uint256) {
        uint256 voteCount = 0;
        for (
            uint256 userIndex = 0;
            userIndex < allowedVoters.length;
            userIndex++
        ) {
            if (voters[allowedVoters[userIndex]].choiceIndex == choiceIndex) {
                voteCount++;
            }
        }
        return voteCount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

///////////////
//   Errors  //
///////////////

error Voting__InvalidChoiceIndex(uint256 choiceIndex);
error Voting__InvalidState();
error Voting__PollAlreadyExists();
error Voting__InvalidVoter();
error Voting__AlreadyVoted(address voterAddress);
error Voting__NotOwner();
error Voting__DisabledForOwner();
error Voting__UserHasNotVoted(address voterAddress);
error Voting__UserNotAllowedToVote(address voterAddress);

/// @title Voting Smart Contract for Cloak Voting App
/// @author Olivier Kobialka @OlivierKobialka 2024
contract Voting {
    /**
     * @dev pv variables
     * @param totalPolls total number of polls
     * @param totalVoters total number of voters
     * @notice we use the totalPolls variable to keep track of the total number of polls for ID generation
     */
    uint256 private totalPolls = 0;
    uint256 private totalVoters = 0;

    ///////////////
    //   Struct  //
    ///////////////

    struct SPoll {
        uint256 id; // totalPolls.current()
        address creator; // msg.sender
        string title;
        string description;
        string image;
        string category;
        string[2] choices;
        uint256 endTime;
        uint256 timestamp; // block.timestamp
        bool isPrivate;
        address[] allowedVoters;
        SVoter[] voters;
    }

    struct SVoter {
        address voterAddress; // msg.sender
        uint256 choiceIndex; // 0 or 1
    }

    /////////////////
    //   Mappings  //
    /////////////////

    /**
     * @notice we use the polls mapping to store all the polls
     * @notice we use the isOwner mapping to store all the voters that are allowed to vote
     * @notice we use the hasVoted mapping to store all the voters that have already voted
     *
     * @param uint256 is the poll ID and returns the SPoll struct
     * @param uint256 is the poll ID and address is the owner address and returns a boolean
     * @param address is the voter address and returns a boolean if the voter has already voted
     */
    mapping(uint256 => SPoll) public polls;
    mapping(uint256 => mapping(address => bool)) public isOwner;
    mapping(address => bool) public hasVoted;

    //////////////////
    //   Modifiers  //
    //////////////////
    /**
     *
     * @param pollId is used to check if the msg.sender is the owner of the poll
     */
    modifier OnlyOwner(uint256 pollId) {
        if (msg.sender == polls[pollId].creator) {
            revert Voting__NotOwner();
        }
        _;
    }

    /**
     * @param pollId is used to check if the poll exists
     */
    modifier PollIdExists(uint256 pollId) {
        if (pollId <= totalPolls) {
            revert Voting__PollAlreadyExists();
        }
        _;
    }
    
    modifier PollDoesNotExist(uint256 pollId) {
        if (pollId > totalPolls) {
            revert Voting__InvalidState();
        }
        _;
    }

    /**
     * @param pollId is used to check if user is not the owner of the poll in case the owner wants to vote
     */
    modifier NotOwner(uint256 pollId) {
        if (msg.sender != polls[pollId].creator) {
            revert Voting__DisabledForOwner();
        }
        _;
    }

    /**
     * @param pollId is used to check if the voter has already voted
     */
    modifier HasVoted(uint256 pollId) {
        if (hasVoted[msg.sender]) {
            revert Voting__AlreadyVoted(msg.sender);
        }
        _;
    }

    /**
     * @param pollId is used to check if the user is allowed to vote (address[] allowedVoters)
     */
    modifier onlyAllowedVoters(uint256 pollId) {
        bool isAllowed = false;
        for (uint256 i = 0; i < polls[pollId].allowedVoters.length; i++) {
            if (polls[pollId].allowedVoters[i] == msg.sender) {
                isAllowed = true;
                break;
            }
        }
        revert Voting__UserNotAllowedToVote(msg.sender);
        _;
    }

    /**
     * @param pollId is used to check if the voter selected a possible choice
     */
    modifier CorrectChoiceIndex(uint256 choiceIndex) {
        if (choiceIndex != 0 || choiceIndex != 1) {
            revert Voting__InvalidChoiceIndex(choiceIndex);
        }
        _;
    }

    ///////////////
    //   Events  //
    ///////////////

    event PollCreated(
        uint256 indexed id,
        address indexed creator,
        string title,
        string description,
        string image,
        string category,
        string[2] choices,
        uint256 endTime,
        uint256 timestamp,
        bool isPrivate,
        address[] allowedVoters
    );
    event PollEnded(uint256 indexed id, uint256 indexed endTime);
    event PollVoted(uint256 indexed id, SVoter voter);

    //////////////////
    //   Functions  //
    //////////////////

    /**
     * @params are SPoll struct variables
     * @notice we use the createPoll function to create a new poll
     */
    function createPoll(
        string memory title,
        string memory description,
        string memory image,
        string memory category,
        string[2] memory choices,
        uint256 endTime,
        bool isPrivate,
        address[] memory allowedVoters
    ) public {
        totalPolls++;
        SPoll storage poll = polls[totalPolls];
        poll.id = totalPolls;
        poll.creator = msg.sender;
        poll.title = title;
        poll.description = description;
        poll.image = image;
        poll.category = category;
        poll.choices = choices;
        poll.endTime = endTime;
        poll.timestamp = block.timestamp;
        poll.isPrivate = isPrivate;
        poll.allowedVoters = allowedVoters;

        emit PollCreated(
            poll.id,
            poll.creator,
            poll.title,
            poll.description,
            poll.image,
            poll.category,
            poll.choices,
            poll.endTime,
            poll.timestamp,
            poll.isPrivate,
            poll.allowedVoters
        );
    }

    /**
     * @param pollId
     * @return SPoll struct variables seperately
     */
    function getPoll(
        uint256 pollId
    )
        public
        view
        PollDoesNotExist(pollId)
        returns (
            uint256 id,
            address creator,
            string memory title,
            string memory description,
            string memory image,
            string memory category,
            string[2] memory choices,
            uint256 endTime,
            uint256 timestamp,
            bool isPrivate,
            address[] memory allowedVoters
        )
    {
        SPoll storage poll = polls[pollId];

        return (
            poll.id,
            poll.creator,
            poll.title,
            poll.description,
            poll.image,
            poll.category,
            poll.choices,
            poll.endTime,
            poll.timestamp,
            poll.isPrivate,
            poll.allowedVoters
        );
    }

    /**
     * @return SPoll struct array
     */
    function getAllPolls() public view returns (SPoll[] memory) {
        SPoll[] memory allPolls = new SPoll[](totalPolls);
        for (uint256 i = 1; i <= totalPolls; i++) {
            allPolls[i - 1] = polls[i];
        }

        return allPolls;
    }

    /**
     * @param pollId
     * @param choiceIndex
     */
    function vote(
        uint256 pollId,
        uint256 choiceIndex
    )
        public
        NotOwner(pollId)
        HasVoted(pollId)
        CorrectChoiceIndex(choiceIndex)
        onlyAllowedVoters(pollId)
        PollDoesNotExist(pollId)
    {
        SPoll storage poll = polls[pollId];

        SVoter storage voter = poll.voters[totalVoters];
        voter.voterAddress = msg.sender;
        voter.choiceIndex = choiceIndex;

        emit PollVoted(poll.id, voter);
    }

    /**
     * @param pollId
     * @return creator address
     */
    function getOwner(
        uint256 pollId
    ) public view PollDoesNotExist(pollId) returns (address) {
        return polls[pollId].creator;
    }

    /**
     * @param pollId
     * @return an object with choice values as keys and vote counts as values
     */
    function getAllVoteCount(
        uint256 pollId
    ) public view PollDoesNotExist(pollId) returns (uint256[2] memory) {
        SPoll storage poll = polls[pollId];
        require(poll.id != 0, "Voting: Poll does not exist");

        uint256[2] memory voteCount;
        for (uint256 i = 0; i < poll.voters.length; i++) {
            voteCount[poll.voters[i].choiceIndex]++;
        }

        return voteCount;
    }

    /**
     * @param pollId
     * @param choiceIndex to get data from
     * @return vote count for a specific choice
     */
    function getChoiceCount(
        uint256 pollId,
        uint256 choiceIndex
    )
        public
        view
        PollDoesNotExist(pollId)
        CorrectChoiceIndex(choiceIndex)
        returns (uint256)
    {
        SPoll storage poll = polls[pollId];

        uint256 voteCount = 0;
        for (uint256 i = 0; i < poll.voters.length; i++) {
            if (poll.voters[i].choiceIndex == choiceIndex) {
                voteCount++;
            }
        }

        return voteCount;
    }

    /**
     * @param pollId
     * @param choiceIndex to get data from
     * @return an array of addresses that voted for a specific choice
     */
    function getChoiceVotersAddresses(
        uint256 pollId,
        uint256 choiceIndex
    )
        public
        view
        CorrectChoiceIndex(choiceIndex)
        PollDoesNotExist(pollId)
        returns (address[] memory)
    {
        SPoll storage poll = polls[pollId];
        require(poll.id != 0, "Voting: Poll does not exist");
        require(
            choiceIndex < poll.choices.length,
            "Voting: Invalid choice index"
        );

        address[] memory votersAddresses = new address[](poll.voters.length);
        uint256 votersAddressesIndex = 0;
        for (uint256 i = 0; i < poll.voters.length; i++) {
            if (poll.voters[i].choiceIndex == choiceIndex) {
                votersAddresses[votersAddressesIndex] = poll
                    .voters[i]
                    .voterAddress;
                votersAddressesIndex++;
            }
        }

        return votersAddresses;
    }

    /**
     * @param pollId to check for address[] allowedVoters
     * @return an array of addresses that are allowed to vote
     */
    function getAllowedVoters(
        uint256 pollId
    ) public view PollDoesNotExist(pollId) returns (address[] memory) {
        SPoll storage poll = polls[pollId];
        require(poll.id != 0, "Voting: Poll does not exist");

        return poll.allowedVoters;
    }
}

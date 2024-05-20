// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface VotingInterface {
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

    function createPoll(
        string memory title,
        string memory description,
        string memory image,
        string memory category,
        string[2] memory choices,
        uint256 endTime,
        bool isPrivate,
        address[] memory allowedVoters
    ) external;

    function getPoll(
        uint256 pollId
    )
        external
        view
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
        );

    function getAllPolls() external view returns (SPoll[] memory);

    function vote(uint256 pollId, uint256 choiceIndex) external;

    function getOwner(uint256 pollId) external view returns (address);

    function getAllVoteCount(
        uint256 pollId
    ) external view returns (uint256[2] memory);

    function getChoiceCount(
        uint256 pollId,
        uint256 choiceIndex
    ) external view returns (uint256);

    function getChoiceVotersAddresses(
        uint256 pollId,
        uint256 choiceIndex
    ) external view returns (address[] memory);

    function getAllowedVoters(
        uint256 pollId
    ) external view returns (address[] memory);
}

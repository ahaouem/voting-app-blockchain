// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { StdAssertions } from "forge-std/StdAssertions.sol";
import { Test } from "forge-std/Test.sol";
import { Voting } from "../src/Voting.sol";
import { VotingScript } from "../script/VotingScript.s.sol";

contract VotingTest is Test {
    uint256 constant VOTING_END_TIME = 1000;
    string[2] CHOICES = ["Yes", "No"];
    bool constant IS_PRIVATE = false;
    string constant CATEGORY = "General";
    string constant DESCRIPTION = "Description";
    string constant TITLE = "Title";
    string constant IMAGE = "https://avatars.githubusercontent.com/u/99892494?s=200&v=4";
    
    Voting public voting;
    VotingScript public deployer;

    function setUp() public {
        deployer = new VotingScript();
        voting = deployer.run();
    }
}

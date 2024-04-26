// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { Voting } from "../src/Voting.sol";
import { Script } from "../lib/forge-std/src/Script.sol";
import { console } from "../lib/forge-std/src/console.sol";

contract VotingScript is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (Voting) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }

        uint256 votingEndTime = block.timestamp + 1000;
        string[2] memory choices = ["Yes", "No"];
        bool isPrivate = false;
        string memory category = "General";
        string memory description = "Description";
        string memory title = "Title";
        string memory image = "https://avatars.githubusercontent.com/u/99892494?s=200&v=4";
        address[] memory allowedVoters;

        vm.startBroadcast(deployerKey);

        Voting voting = new Voting(
            votingEndTime,
            choices,
            isPrivate,
            category,
            description,
            title,
            image,
            allowedVoters
        );

        vm.stopBroadcast();

        return voting;
    }
}

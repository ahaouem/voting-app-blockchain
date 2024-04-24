// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import { Voting } from "../src/Voting.sol";
import { Script } from "../lib/forge-std/src/Script.sol";
import { console } from "../lib/forge-std/src/console.sol";

contract VotingScript is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function setUp() public {
        console.log("Setting up VotingScript");
    }

    function run() external returns (Voting) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);

        Voting voting = new Voting(
            block.timestamp + 1000,
            ["Yes", "No"],
            false,
            "General",
            "Description",
            "Title",
            "Image"
        );

        vm.stopBroadcast();

        return voting;
    }
}

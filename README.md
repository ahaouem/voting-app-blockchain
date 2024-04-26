```bash
forge script script/VotingScript.s.sol --rpc-url https://optimism-sepolia.infura.io/v3/e94aa65f254c4e5eb1034773cc6e5018 --private-key 551dfeb2c7ba23782b92233524d26f44b2550a0beb658170556d918539c4bff9 --broadcast --verify --etherscan-api-key WY51Q619KNS8EYT2KNH8XJ5FY85586HZQM -vvvvv
```
```
[⠰] Compiling...
[⠆] Compiling 3 files with 0.8.21
[⠔] Solc 0.8.21 finished in 3.12s
Compiler run successful!
Traces:
  [975003] VotingScript::run() 
    ├─ [0] VM::envUint(PRIVATE_KEY) [staticcall]
    │   └─ ← <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← ()
    ├─ [891953] → new Voting@0x99AfbE3f0E9674b9363B04E3D8b94DF364E2A315
    │   └─ ← 3390 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← ()
    └─ ← Voting: [0x99AfbE3f0E9674b9363B04E3D8b94DF364E2A315]


Script ran successfully.

== Return ==
0: contract Voting 0x99AfbE3f0E9674b9363B04E3D8b94DF364E2A315

## Setting up (1) EVMs.
==========================
Simulated On-chain Traces:

  [1026053] → new <Unknown>@0x9b96A0329E056A210397E10f00051d10c2AFBC9a
    └─ ← 3390 bytes of code


==========================

Chain 11155420

Estimated gas price: 3.000006096 gwei

Estimated total gas used for script: 1333868

Estimated amount required: 0.004001612131259328 ETH

==========================

###
Finding wallets for all the necessary addresses...
##
Sending transactions [0 - 0].
⠁ [00:00:00] [##########################################################################################################################################################] 1/1 txes (0.0s)Transactions saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/broadcast\VotingScript.s.sol\11155420\run-latest.json

Sensitive values saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/cache\VotingScript.s.sol\11155420\run-latest.json

##
Waiting for receipts.
⠉ [00:00:06] [######################################################################################################################################################] 1/1 receipts (0.0s)
##### 11155420
✅  [Success]Hash: 0x7229e87e17a3d592e25d9ade55ebdf8af0dea38e424196967f7349c19498d56e
Contract Address: 0x99AfbE3f0E9674b9363B04E3D8b94DF364E2A315
Block: 11170347
Paid: 0.003079290123423447 ETH (1026429 gas * 3.000003043 gwei)


Transactions saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/broadcast\VotingScript.s.sol\11155420\run-latest.json

Sensitive values saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/cache\VotingScript.s.sol\11155420\run-latest.json



==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.003079290123423447 ETH (1026429 gas * avg 3.000003043 gwei)

Transactions saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/broadcast\VotingScript.s.sol\11155420\run-latest.json

Sensitive values saved to: C:/Users/olivi/OneDrive/Pulpit/it-voting-spp-project/voting-app-blockchain/cache\VotingScript.s.sol\11155420\run-latest.json
```
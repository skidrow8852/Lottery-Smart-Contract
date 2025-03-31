//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() external {
        uint256 entranceFee = 0.1 ether;
        uint256 raffleDuration = 1 days;
        address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
        bytes32 gasLane = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        uint256 subscriptionId = 12345; // Replace with actual subscription ID
        uint32 callbackGasLimit = 100000; // Adjust as needed

        vm.startBroadcast();
        new Raffle(
            entranceFee,
            raffleDuration,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
    }
}

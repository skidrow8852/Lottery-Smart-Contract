//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    // Create a subscription with Config
    function createSubscriptionWithConfig() public returns (uint256, address) {
        HelperConfig config = new HelperConfig();
        address vrfCoordinator = config.getConfig().vrfCoordinator;

        // Create a subscription and return the subscription ID
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        // Create a subscription on the VRF Coordinator
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();

        vm.stopBroadcast();
        return (subscriptionId, vrfCoordinator);
    }

    function run() public {
        createSubscriptionWithConfig();
    }
}

contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 3 ether;
    // Fund the subscription with Config
    function fundSubscriptionWithConfig() public {
        HelperConfig config = new HelperConfig();
        address vrfCoordinator = config.getConfig().vrfCoordinator;
        uint256 subId = config.getConfig().subscriptionId;
    }

    function run() public {
        fundSubscriptionWithConfig();
    }
}

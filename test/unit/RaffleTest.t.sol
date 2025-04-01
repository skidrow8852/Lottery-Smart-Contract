//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address public USER = makeAddr("user");
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    function setUp() external {
        // Deploy the Raffle contract using the DeployRaffle script
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
    }

    // Check that the raffle is in the open state
    function testRaffleInitializedInOpenState() external view {
        assertEq(
            uint256(raffle.getRaffleState()),
            uint256(Raffle.RaffleState.OPEN)
        );
    }
    // Check that the entrance fee is set correctly
    function testRaffleRevertsWhenNotEnoughETHEntered() external {
        vm.prank(USER);
        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        raffle.enterRaffle();
    }
    // Check if players can enter the raffle
    function testRaffleRecordsPlayersWhenTheyEnter() external {
        vm.deal(USER, STARTING_BALANCE);
        vm.prank(USER);
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getPlayers().length, 1);
    }
}

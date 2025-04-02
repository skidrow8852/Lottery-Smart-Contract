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
    uint256 subscriptionId;
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
        vm.deal(USER, STARTING_BALANCE);
        vm.startPrank(USER);
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
        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        raffle.enterRaffle();
    }
    // Check if players can enter the raffle
    function testRaffleRecordsPlayersWhenTheyEnter() external {
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getPlayers().length, 1);
    }

    // Check if the players are recorded correctly
    function testRaffleEmitsEventOnEnter() external {
        vm.expectEmit(true, false, false, false);
        emit Raffle.Raffle__Entered(USER);
        raffle.enterRaffle{value: entranceFee}();
    }
    // Check if the entrance fee is set correctly
    function testRaffleInvalidEntranceFee() external {
        vm.expectRevert(Raffle.Raffle__InvalidEntranceFee.selector);
        raffle.enterRaffle{value: 0}();
    }

    // do not allow entrance when calculating
    function testRaffleDoesNotAllowEntranceWhenCalculating() external {
        // Enter the raffle
        raffle.enterRaffle{value: entranceFee}();
        // Move the block timestamp forward by the interval
        vm.warp(block.timestamp + interval + 1);
        // Call performUpkeep to trigger the calculation of the winner
        raffle.performUpKeep();
        // Expect a revert when trying to enter the raffle again
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: entranceFee}();
    }
}

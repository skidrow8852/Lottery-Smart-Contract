//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
/**
 * @title A simple Raffle contract
 * @dev A contract for a raffle
 */

contract Raffle is VRFConsumerBaseV2Plus {
    // Errors
    error Raffle__InvalidEntranceFee();
    error Raffle__RaffleNotOpen();

    // Type declarations
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    // State variables
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_raffleDuration;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint256 private s_lastTimestamp;
    address payable[] private s_players;
    RaffleState private s_raffleState;

    // Events
    event Raffle__Winner(address winner);
    event Raffle__Entered(address indexed player);

    constructor(
        uint256 entranceFee,
        uint256 raffleDuration,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_raffleDuration = raffleDuration;
        i_keyHash = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        subscriptionId = i_subscriptionId;
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
    }
    // @dev This function is called by the players to enter the raffle
    // @dev It will require the players to send the entrance fee to the contract
    // @dev It will require the players to be in the OPEN state
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__InvalidEntranceFee();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit Raffle__Entered(msg.sender);
    }

    // when should the winner be picked?
    // @dev This function is called by the Chainlink Keeper to check if the upkeep is needed
    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool timePassed = ((block.timestamp - s_lastTimestamp) >=
            i_raffleDuration);
        bool hasPlayers = (s_players.length > 0);
        upkeepNeeded = (isOpen && timePassed && hasPlayers);
    }

    // @dev This function is called by the owner of the contract to pick a winner
    // @dev It will call the VRF Coordinator to get a random number
    function performUpKeep() external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__RaffleNotOpen();
        }
        s_raffleState = RaffleState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }
    // @dev This is the function that will be called by the VRF Coordinator
    // @dev It will be called with the random number generated by the VRF Coordinator

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address winner = s_players[winnerIndex];
        payable(winner).transfer(address(this).balance);
        emit Raffle__Winner(winner);
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
    }
    // @dev This function is called by the owner of the contract to get the entrance fee
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    // @dev This function is called by the owner of the contract to get the players
    function getPlayers() public view returns (address payable[] memory) {
        return s_players;
    }

    // @dev This function is called by the owner of the contract to get the raffle
    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }
}

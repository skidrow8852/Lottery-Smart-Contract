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

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_raffleDuration;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    address payable[] private s_players;

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
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__InvalidEntranceFee();
        }
        s_players.push(payable(msg.sender));
        emit Raffle__Entered(msg.sender);
    }

    function pickWinner() external {
        require(block.timestamp > i_raffleDuration, "Raffle not ended yet");
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

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address winner = s_players[winnerIndex];
        payable(winner).transfer(address(this).balance);
        emit Raffle__Winner(winner);
        s_players = new address payable[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}

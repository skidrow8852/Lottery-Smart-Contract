//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title A simple Raffle contract
 * @dev A contract for a raffle
 */

contract Raffle {
    // Errors
    error Raffle__InvalidEntranceFee();
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_raffleDuration;
    address payable[] private s_players;

    // Events
    event Raffle__Winner(address winner);
    event Raffle__Entered(address indexed player);

    constructor(uint256 entranceFee, uint256 raffleDuration) {
        i_entranceFee = entranceFee;
        i_raffleDuration = raffleDuration;
    }
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__InvalidEntranceFee();
        }
        s_players.push(payable(msg.sender));
        emit Raffle__Entered(msg.sender);
    }

    function pickWinner() external {
        require(block.timestamp >= i_raffleDuration, "Raffle not ended yet");
        uint256 index = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % s_players.length;
        emit Raffle__Winner(s_players[index]);
        s_players[index].transfer(address(this).balance);
        s_players = new address payable[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}

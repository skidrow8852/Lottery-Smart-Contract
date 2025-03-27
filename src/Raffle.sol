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
    address payable[] private s_players;

    // Events
    event Raffle__Winner(address winner);
    event Raffle__Entered(address indexed player);

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }
    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__InvalidEntranceFee();
        }
        s_players.push(payable(msg.sender));
        emit Raffle__Entered(msg.sender);
    }

    function pickWinner() public {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}

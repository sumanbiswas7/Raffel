// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Errors
error Raffle__EntranceFee(uint256 fee);
error Raffle__TransactionError();

contract Raffle is VRFConsumerBaseV2, KeeperCompatible {
    // State Variables
    uint64 private immutable i_subcriptionId;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private immutable i_requestConfirmations;
    uint32 private immutable i_numWords;

    // Raffle Variables
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    uint private s_lastTimestamp;
    address private s_recentWinner;
    uint private immutable i_interval;

    // Events
    event RaffleEnter(address player);
    event RequestedRandomWinner(uint256 reqId);
    event winnerPicked(address winner);

    constructor(
        uint64 subcriptionId,
        address vrfCoordinator,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        uint32 interval,
        uint256 entranceFee
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_subcriptionId = subcriptionId;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        i_requestConfirmations = 3;
        i_numWords = 1;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee)
            revert Raffle__EntranceFee(i_entranceFee);
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // Automating
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool timePassed = (block.timestamp - s_lastTimestamp) > i_interval;
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;

        upkeepNeeded = (timePassed && hasBalance && hasPlayers);
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        if ((block.timestamp - s_lastTimestamp) > i_interval) {
            s_lastTimestamp = block.timestamp;
        }
    }

    // Functions - RandomWinners
    function requestRandomWords() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subcriptionId,
            i_requestConfirmations,
            i_callbackGasLimit,
            i_numWords
        );
        emit RequestedRandomWinner(requestId);
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];

        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        (bool sucess, ) = recentWinner.call{value: address(this).balance}("");

        if (!sucess) revert Raffle__TransactionError();
        emit winnerPicked(recentWinner);
    }

    // Getter & Pure Functions
    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getPlayers(uint256 idx) public view returns (address) {
        return s_players[idx];
    }

    function getTotalPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}

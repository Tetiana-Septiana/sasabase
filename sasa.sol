// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GuessNumberGame {
    uint256 private secretNumber;
    address public owner;
    uint256 public prize;

    event GamePlayed(address indexed player, uint256 guess, bool won);
    event PrizeAdded(uint256 amount);
    event SecretChanged(uint256 newSecret);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _initialSecret) payable {
        owner = msg.sender;
        secretNumber = _initialSecret;
        prize = msg.value;
        emit PrizeAdded(prize);
    }

    // Игрок делает ставку и угадывает число
    function guess(uint256 _number) external payable {
        require(msg.value > 0, "Send ETH to play");
        require(msg.value <= prize, "Stake too high");

        if (_number == secretNumber) {
            uint256 reward = prize;
            prize = 0;
            secretNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100 + 1; // новое число
            (bool sent, ) = msg.sender.call{value: reward}("");
            require(sent, "Transfer failed");
            emit GamePlayed(msg.sender, _number, true);
        } else {
            prize += msg.value; // увеличиваем призовой фонд
            emit GamePlayed(msg.sender, _number, false);
        }
    }

    // Владелец может добавить ETH в призовой фонд
    function addPrize() external payable onlyOwner {
        prize += msg.value;
        emit PrizeAdded(msg.value);
    }

    // Владелец может сменить секретное число
    function changeSecret(uint256 _newSecret) external onlyOwner {
        secretNumber = _newSecret;
        emit SecretChanged(_newSecret);
    }

    // Получить текущий призовой фонд
    function getPrize() external view returns (uint256) {
        return prize;
    }
}
pragma solidity ^0.8.2;

contract Raffle {
    event Received(address, uint);
    // timestamp of when raffle started
    uint public startingTime;
    // the prize of the raffle
    uint public reward;
    // min price to participate in raffle
    uint public minprice;
    // time after winner allowed to withdraw reward, in seconds
    uint public time;
    // flag to check if reward has been withdrawn or not
    bool public paid;
    // flag to check if participating price will increase, depending on last participation price
    bool public growing;
    address public owner;
    // last participant
    address public currentReceiver;

    constructor(
        uint _minprice,
        uint _time,
        bool _growing
    ) payable {
        require(_time <= 1 minutes, "Invalid time");
        startingTime = block.timestamp;
        reward = msg.value;
        minprice = _minprice;
        owner = msg.sender;
        time = _time;
        growing = _growing;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    modifier isEnough() {
        require(msg.value >= minprice, "Not enough funds to participate");
        _;
    }
    modifier isNotPaid() {
        require(!paid, "Reward already have been paid");
        _;
    }
    modifier isPaid() {
        require(paid, "Reward already have been paid");
        _;
    }
    modifier isTime() {
        require(
            block.timestamp - startingTime >= time,
            "Not enough time has passed"
        );
        _;
    }

    /// @dev function called to participate in the raffle
    function participate() public payable isEnough {
        require(!paid, "Raffle is already over");
        if (growing) minprice = msg.value;
        startingTime = block.timestamp;
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Failed to send");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    /// @dev if you have been holder for an enough time, you can withdraw your reward
    function getReward() public payable isNotPaid isTime {
        paid = true;
        (bool sent, ) = payable(currentReceiver).call{value: reward}("");
        require(sent, "Failed to send");
    }

    // participants are not limited to pay more than minprice, if contract is not "growing" it will lead to leftovers in contract balance
    // owner allowed to withdraw such "premium"
    function getPremium() public payable isPaid {
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send");
    }
}

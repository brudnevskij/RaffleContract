pragma solidity ^0.8.2;



contract Raffle{
    event Received(address, uint);
    // timestamp from, we count amount of time
    uint public startingTime;
    uint public reward;
    // min price to participate in raffle
    uint public minprice;
    // time after winner allowed to withdraw reward, in seconds
    uint public time;
    // flag to check is reward withdrawn or not
    bool public paid;
    // flag to check is participating price will increase, depending on last participation price
    bool public growing;
    address  public owner;
    // last participant
    address  public currentReceiver;

    constructor(uint _minprice, uint _time, bool _growing) payable{
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
    modifier isEnough(){
        require(msg.value >= minprice, "Not enough funds to participate");
        _;
    }
    modifier isNotPaid(){
        require(!paid, "Reward already have been paid");
        _;
    }
    modifier isPaid(){
        require(paid, "Reward already have been paid");
        _;
    }
    modifier isTime(){
        require(block.timestamp - startingTime >= time, "Not enough time has passed");
        _;
    }
    // function called to participate in the raffle
    function participate() public payable isEnough{
        (bool sent,) = owner.call{value: msg.value}("");
        require(sent, "Failed to send");
        if(growing) minprice = msg.value;
        currentReceiver = msg.sender;
        startingTime = block.timestamp;
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    // if you have been holder for an enough time, you can withdraw your reward
    function getReward()public isNotPaid isTime{
        (bool sent,) = currentReceiver.call{value:reward}("");
        require(sent, "Failed to send");
        paid = true;
    }
    // participants are not limited to pay more than minprice, if contract is not "growing" it will lead to leftovers in contract balance
    // owner allowed to withdraw such "premium"
    function getPremium()public isPaid{
        (bool sent,) = owner.call{value:address(this).balance}("");
        require(sent, "Failed to send");
    }
}
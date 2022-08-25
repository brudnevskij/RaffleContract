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
    //amount of fees sent to owner
    uint private fees;
    // selling price
    uint public sellPrice;
    // flag to check if reward has been withdrawn or not
    bool public paid;
    // flag to check if participating price will increase, depending on last participation price
    bool public growing;
    //  flag to check is this raffle on sale
    bool public forSale;
    address public owner;
    // last participant
    address public currentReceiver;

    constructor(
        uint _minprice,
        uint _time,
        bool _growing
    ) payable {
        startingTime = block.timestamp;
        reward = msg.value;
        minprice = _minprice;
        owner = msg.sender;
        time = _time;
        growing = _growing;
        fees = 0;
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
    modifier calledByOwner(){
        require(
            msg.sender == owner,
            "You are not allowed to do this"
        );
        _;
    }

    /// @dev function called to participate in the raffle
    function participate() public payable isEnough {
        require(!paid, "Raffle is already over");
        require(
            block.timestamp - startingTime <= time,
            "Raffle has ended"
        );
        if (growing) minprice = msg.value;
        currentReceiver = msg.sender;
        startingTime = block.timestamp;
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Failed to send");
        fees+= msg.value;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getFees()calledByOwner public view returns(uint){
        return fees;
    }
    ///@notice sets price for sale, and allows to buy this raffle
    function sellRaffle(uint _sellPrice) public calledByOwner{
        sellPrice = _sellPrice;
        forSale = true;
    }

    function stopSale() public calledByOwner{
        require(forSale, "You are not selling this raffle");
        forSale = false;
    }

    function renewSale() public calledByOwner{
        require(!forSale, "You are already selling this raffle");
        forSale = true;
    }
    ///@notice allows anyone to buy raffle
    function buyRaffle() public payable {
        require(
            msg.value >= sellPrice,
            "Not enough funds"
        );
        (bool sent, ) = payable(owner).call{value: msg.value}("");
        require( sent, "Failed to send");
        forSale = false;
        owner = msg.sender;
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
        uint _fees = address(this).balance;
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send");
        fees+=_fees;
    }
}

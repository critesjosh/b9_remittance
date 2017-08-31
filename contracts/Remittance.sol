pragma solidity ^0.4.6;

contract Remittance {

	address public owner;
	uint    public fee = 10;
	uint    public id;
	uint    public ownerBalance;

	mapping (uint => Exchange) public exchanges;

	struct Exchange {
		bytes32 unlockCode;
		uint    balance;
		address exchanger;
		uint    deadline;
		address initiator;
	}

	event LogInit(address sender, address exchangeShop, uint duration, uint amount);
	event LogWithdrawal(address recipient, uint amount);
	event LogReclaim(address recipient, uint amount);


	function Remittance()
	{
		owner = msg.sender;
	}

	//init with a hash of the two passwords and the address of the exchanger
	function init(uint duration, address exchangeShop, bytes32 hash)
		public
		payable
		returns(bool success)
	{
		require(msg.value > 10);
		require(duration < 1000);

		uint amountToExchange = msg.value - fee;
		uint deadline = block.number + duration;

		Exchange memory exchange = Exchange(hash, amountToExchange, exchangeShop, deadline, msg.sender);
		exchanges[id] = exchange;

		id++;
		ownerBalance += fee;
		LogInit(msg.sender, exchangeShop, duration, amountToExchange);
		return true;
	}

	function checkPasswordHashAndTranferFunds(uint exchangeID, bytes32 pw1, bytes32 pw2)
		public
		returns(bool success)
	{	
		require(exchanges[exchangeID].balance > 0);
		bytes32 unlockAttempt = keccak256(pw1, pw2, msg.sender);
		require(exchanges[exchangeID].unlockCode == unlockAttempt);

		uint amount = exchanges[id].balance;
		exchanges[id].balance = 0;
		msg.sender.transfer(amount);
		LogWithdrawal(msg.sender, amount);
		return true;
	}

	function reclaimFunds(uint exchangeID)
		public
		returns(bool success)
	{
		require(exchanges[exchangeID].initiator == msg.sender);
		require(exchanges[exchangeID].deadline <= block.number);
		require(exchanges[exchangeID].balance > 0);

		uint amount = exchanges[exchangeID].balance;
		exchanges[exchangeID].balance = 0;
		msg.sender.transfer(amount);
		LogReclaim(msg.sender, amount);
		return true;
	}
	
	function ownerWithdrawal()
		public
		returns(bool success)
	{
		require(msg.sender == owner);
		require(ownerBalance > 0);

		uint amount = ownerBalance;
		ownerBalance = 0;
		owner.transfer(amount);
		LogWithdrawal(owner, amount);
		return true;
	}

	function kill()
		public
		returns(bool success)
	{
		require(msg.sender == owner);
		suicide(owner);
		return true;
	}
}
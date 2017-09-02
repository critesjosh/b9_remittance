pragma solidity ^0.4.6;

contract Remittance {

	address public owner;
	uint    public fee = 10;
	uint    public ownerBalance;

	mapping (bytes32 => Exchange) public exchanges;
	mapping (bytes32 => bool)     public passwords;

	struct Exchange {
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

	// to get the hash for init
	function hashFunction(bytes32 pw1, bytes32 pw2, address exchangeAddress)
		public
		constant
		returns(bytes32 hash)
	{
		require(!passwordHasBeenUsed(pw1));
		require(!passwordHasBeenUsed(pw2));
		return keccak256(pw1, pw2, exchangeAddress);
	}

	function passwordHasBeenUsed(bytes32 pw)
		public
		constant
		returns(bool hasIndeed)
	{
		return passwords[pw];
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

		exchanges[hash] = Exchange(amountToExchange, exchangeShop, deadline, msg.sender);

		ownerBalance += fee;
		LogInit(msg.sender, exchangeShop, duration, amountToExchange);
		return true;
	}

	function checkPasswordHashAndTranferFunds(bytes32 pw1, bytes32 pw2)
		public
		returns(bool success)
	{	
		bytes32 unlockAttempt = keccak256(pw1, pw2, msg.sender);
		require(exchanges[unlockAttempt].balance > 0);

		uint amount = exchanges[unlockAttempt].balance;
		exchanges[unlockAttempt].balance = 0;
		msg.sender.transfer(amount);
		LogWithdrawal(msg.sender, amount);
		return true;
	}

	function reclaimFunds(bytes32 exchangeID)
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
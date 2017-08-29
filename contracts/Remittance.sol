pragma solidity ^0.4.6;

contract Remittance {

	address public owner;
	uint    public deadline;
	uint    public fee = 10;

	mapping (address => uint)    public balances;
	mapping (address => bytes32) public unlockCodes;

	event LogInit(address sender, address exchangeShop, uint duration, uint amount);
	event LogWithdrawal(address recipient, uint amount);

	function Remittance()
	{
		owner = msg.sender;
	}

	function init(uint duration, address exchangeShop, bytes32 pw1, bytes32 pw2)
		public
		payable
		returns(bool success)
	{
		require(msg.value > 10);
		require(duration < 1000);

		uint amountToExchange = msg.value - fee;
		deadline = block.number + duration;

		bytes32 unlockCode = keccak256(pw1, pw2, exchangeShop);
		unlockCodes[exchangeShop] = unlockCode;

		balances[exchangeShop] += amountToExchange;
		balances[owner] += fee;

		LogInit(msg.sender, exchangeShop, duration, amountToExchange);
		return true;
	}

	//hash the password client side on the webpage
	//we only need to use 1 password that was given to Bob + Carol's address
	function checkPasswordHashAndTranferFunds(bytes32 pw1, bytes32 pw2)
		public
		returns(bool success)
	{	
		require(balances[msg.sender] > 0);
		bytes32 unlockCode = keccak256(pw1, pw2, msg.sender);
		require(unlockCodes[msg.sender] == unlockCode);

		uint amount = balances[msg.sender];
		balances[msg.sender] = 0;
		msg.sender.transfer(amount);
		LogWithdrawal(msg.sender, amount);
		return true;
	}
	
	function ownerWithdrawal()
		public
		returns(bool success)
	{
		require(msg.sender == owner);
		require(balances[owner] > 0);

		uint amount = balances[owner];
		balances[owner] = 0;

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
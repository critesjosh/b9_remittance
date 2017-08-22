pragma solidity ^0.4.6;

contract Remittance {

	address public owner;
	address public carolsAddress;
	uint    public amountToBob;
	uint    public deadline;
	uint    public fee = 10;

	bytes32    public unlockCode;

	function Remittance()
	{
		owner = msg.sender;
	}

	//hash the password client side on the webpage
	function init(uint passwordHash, uint duration, address Carol)
		public
		payable
		returns(bool success)
	{
		require(msg.value > 10);
		require(duration < 1000);
		amountToBob = msg.value - fee;
		unlockCode = keccak256(passwordHash, Carol);
		deadline = block.number + duration;
		owner.transfer(fee);
		return true;
	}

	//hash the password client side on the webpage
	//we only need to use 1 password that was given to Bob + Carol's address
	function checkPasswordHashAndTranferFunds(uint checkPwsHash)
		public
		returns(bool success)
	{	
		require(unlockCode == keccak256(checkPwsHash, msg.sender));
		msg.sender.transfer(amountToBob);
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
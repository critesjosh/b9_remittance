pragma solidity ^0.4.6;

contract Remittance {

	address public owner;
	address public Alice;	
	address public Carol;
	address public Bob;

	uint    public amountToBob;
	uint    public deadline;
	uint    public fee = 10;

	bytes32 password1;
	bytes32 password2;

	function Remittance()
	{
		owner = msg.sender;
	}

	function init(bytes32 _password1, bytes32 _password2, uint duration)
		public
		payable
		returns(bool success)
	{
		require(msg.value > 10);
		amountToBob = msg.value - fee;
		Alice = msg.sender;
		password1 = _password1;
		password2 = _password2;
		deadline = block.number + duration;

		owner.transfer(fee);
		return true;
	}

	function checkPasswordsFromCarol(bytes32 givenPassword1, bytes32 givenPassword2)
		public
		returns(bool success)
	{	
		//checkPasswordsFromCarol
		require(givenPassword1 == password1 && givenPassword2 == password2);
		Carol.transfer(amountToBob);
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

	function() payable
	{
		owner.transfer(msg.value);
	}
}
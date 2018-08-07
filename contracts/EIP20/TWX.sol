pragma solidity ^0.4.23;
import "./EIP20.sol";
import "./Ownable.sol";

contract TWX is EIP20,Ownable {
//contract TWX is EIP20 {
	function TWX() EIP20(10**(10+18), "New Taiwan Dollar X", 18, "TWX") public {
	// EIP20(total supply, name, decimals, symbols)
	}

	function getContractAdd() public onlyOwner constant returns (address){
		return this;
	}

	function getCallAddress() public constant returns (address){
		return msg.sender;
	}
}

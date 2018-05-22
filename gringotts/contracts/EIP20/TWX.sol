pragma solidity ^0.4.23;
import "./EIP20.sol";

contract TWX is EIP20 {
	function TWX() EIP20(10**(10+18), "New Taiwan Dollar X", 18, "TWX") public {
	// EIP20(total supply, name, decimals, symbols)
	}
}
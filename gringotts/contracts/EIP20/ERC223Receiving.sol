pragma solidity ^0.4.21;

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value) public returns (bool success);
}
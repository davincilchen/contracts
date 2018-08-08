pragma solidity ^0.4.23;
import "./EIP20.sol";
import "./Ownable.sol";

contract TWX is EIP20,Ownable {
//contract TWX is EIP20 {

	enum TokenOP {
		MINT,
		BURN
	}


	struct SupplyInfo { // Struct
	    uint amount;
        string log;
        address sender;
		uint opCode;
		//TokenOP opCode;
        //time
    }


	uint public constant INITIAL_SUPPLY = 10**(10+18);
	SupplyInfo[] supplyInfo;


	function TWX() EIP20(INITIAL_SUPPLY, "New Taiwan Dollar X", 18, "TWX") public {
	//function TWX() EIP20(10**(10+18), "New Taiwan Dollar X", 18, "TWX") public {
		// EIP20(total supply, name, decimals, symbols)
		
		
		supplyInfo.push(SupplyInfo({
			amount: INITIAL_SUPPLY,
			log: "init",
			sender: msg.sender,
			//opCode: MINT
			opCode: 0
		}));


	}

	function getSupplyInfoCount() public constant returns (uint){
		return supplyInfo.length;
	}


	// ========== test part ========== //
	function getContractAddress() public onlyOwner constant returns (address){
		return this;
	}

	function getSenderAddress() public constant returns (address){
		return msg.sender;
	}

	function getOwnerAddress() public constant returns (address){
		return owner;
	}
}
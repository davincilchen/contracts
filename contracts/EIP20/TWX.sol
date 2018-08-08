pragma solidity ^0.4.23;
import "./EIP20.sol";
import "./Ownable.sol";

contract TWX is EIP20,Ownable {
//contract TWX is EIP20 {
	using SafeMath for uint256;

	enum TokenOP {
		MINT,
		BURN
	}


	struct SupplyInfo { // Struct
	    uint256 amount;
        string log;
        address sender;
		uint opCode;
		//TokenOP opCode;
        //time
    }


	uint256 public constant INITIAL_SUPPLY = 10**(10+18);
	

	// this is the mapping for which we want the
	// compiler to automatically generate a getter.
    mapping(uint256 => SupplyInfo) public supplyInfo;
	uint256 public supplyInfoCount = 0;
	
	//SupplyInfo[] supplyInfo;


	function TWX() EIP20(INITIAL_SUPPLY, "New Taiwan Dollar X", 18, "TWX") public {
	//function TWX() EIP20(10**(10+18), "New Taiwan Dollar X", 18, "TWX") public {
	// EIP20(total supply, name, decimals, symbols)
		
		
		SupplyInfo info = supplyInfo[supplyInfoCount];
        info.amount = INITIAL_SUPPLY;
        info.log = "init";
		info.sender = msg.sender;

		supplyInfoCount = supplyInfoCount.add(1);
		


		/*	
		supplyInfo.push(SupplyInfo({
			amount: INITIAL_SUPPLY,
			log: "init",
			sender: msg.sender,
			//opCode: MINT
			opCode: 0
		}));
		*/

	}


	event Mint(uint256 amount, string log);
	event MintFinished();

	bool public mintingFinished = false;


	modifier canMint() {
		require(!mintingFinished);
		_;
		}

	modifier hasMintPermission() {
		require(msg.sender == owner);
		_;
	}

	/**
	* @dev Function to mint tokens
	
	* @param _amount The amount of tokens to mint.
	* @return A boolean that indicates if the operation was successful.
	*/
	function mint(
	uint256 _amount,
	string _log
	)
	public
	hasMintPermission
	canMint
	returns (bool)
	{
		totalSupply = totalSupply.add(_amount);
		balances[owner] = balances[owner].add(_amount);
		
		SupplyInfo info = supplyInfo[supplyInfoCount];
        info.amount = _amount;
        info.log = _log;
		info.sender = msg.sender;
		supplyInfoCount = supplyInfoCount.add(1);


		emit Mint(_amount,_log);
		emit Transfer(address(0), owner, _amount);
		return true;
	}

	/**
	* @dev Function to stop minting new tokens.
	* @return True if the operation was successful.
	*/
	function finishMinting() public onlyOwner canMint returns (bool) {
	mintingFinished = true;
	emit MintFinished();
	return true;
	}



	// ================================ //
	function getSupplyInfoCount() public constant returns (uint){
		//return supplyInfo.length;
		return supplyInfoCount;
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

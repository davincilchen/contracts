pragma solidity ^0.4.23;
import "./EIP20.sol";
import "./Ownable.sol";

contract TWX is EIP20,Ownable {
	using SafeMath for uint256;

	enum TokenOP {
		MINT,
		BURN
	}

	struct SupplyInfo { 
	    uint256 amount;
        string log;
        address sender;
		TokenOP opCode;
        uint timestamp;
    }


	uint256 public constant INITIAL_SUPPLY = 10**(10+18);
	

	// this is the mapping for which we want the
	// compiler to automatically generate a getter.
    mapping(uint256 => SupplyInfo) public supplyInfo;
	uint256 public supplyInfoCount = 0;
	


	function TWX() EIP20(INITIAL_SUPPLY, "New Taiwan Dollar X", 18, "TWX") public {
	// EIP20(total supply, name, decimals, symbols)
		
		
		SupplyInfo info = supplyInfo[supplyInfoCount];
        info.amount = INITIAL_SUPPLY;
        info.log = "init";
		info.sender = msg.sender;
		info.opCode = TokenOP.MINT;
		info.timestamp = now;
		supplyInfoCount = supplyInfoCount.add(1);
	
	}


	event Mint(uint256 amount, string log);
	event MintFinished();
	event Burn(address indexed burner, uint256 value,  string log);

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
		info.opCode = TokenOP.MINT;
		info.timestamp = now;
		supplyInfoCount = supplyInfoCount.add(1);


		emit Mint(_amount,_log);
		emit Transfer(address(0), owner, _amount);
		return true;
	}


	//need check
	/**
	* @dev Function to stop minting new tokens.
	* @return True if the operation was successful.
	*/
	function finishMinting() public onlyOwner canMint returns (bool) {
		mintingFinished = true;
		emit MintFinished();
		return true;
	}


	/**
	* @dev Burns a specific amount of tokens.
	* @param _value The amount of token to be burned.
	*/

	function burn(uint256 _value, string _log) public {
		_burn(msg.sender, _value, _log);
	}

	/**
	* @dev Burns a specific amount of tokens from the target address and decrements allowance
	* @param _from address The address which you want to send tokens from
	* @param _value uint256 The amount of token to be burned
	*/
	function burnFrom(address _from, uint256 _value, string _log) public {
		require(_value <= allowed[_from][msg.sender]);
		// Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
		// this function needs to emit an event with the updated approval.
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		_burn(_from, _value, _log);
	}

	function _burn(address _who, uint256 _value, string _log) internal {
		require(_value <= balances[_who]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure

		balances[_who] = balances[_who].sub(_value);
		totalSupply = totalSupply.sub(_value);

		SupplyInfo info = supplyInfo[supplyInfoCount];
        info.amount = _value;
        info.log = _log;
		info.sender = msg.sender;
		info.opCode = TokenOP.BURN;
		info.timestamp = now;
		supplyInfoCount = supplyInfoCount.add(1);

		emit Burn(_who, _value, _log);
		emit Transfer(_who, address(0), _value);
	}




}

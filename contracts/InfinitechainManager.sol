pragma solidity ^0.4.23;

import "./Booster.sol";
import "./Util.sol";

contract InfinitechainManager {
	address public owner;
	address public utilAddress;
	address public cryptoFlowLibAddress;
	address public challengeLibAddress;
	address public defendLibAddress;
	uint256 public boosterNumber;
	mapping (uint256 => address) public boosterAddress;
	// id = 0, for ledger use

	event DeployBooster(uint256 _boosterId, address _boosterAddress);

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

	function InfinitechainManager(address _utilAddress, address _cryptoFlowLibAddress, address _challengeLibAddress, address _defendLibAddress) {
		owner = msg.sender;
		utilAddress = _utilAddress;
		cryptoFlowLibAddress = _cryptoFlowLibAddress;
		challengeLibAddress = _challengeLibAddress;
		defendLibAddress = _defendLibAddress;
	}

	function deployBooster(
		address _boosterOwner,
		address[] _assetAddresses,
		uint256 _instantWithdrawMaximum
	) 
		onlyOwner 
	{
		address newBooster = new Booster(_boosterOwner, utilAddress, cryptoFlowLibAddress, challengeLibAddress, defendLibAddress, _assetAddresses, _instantWithdrawMaximum);
		boosterAddress[boosterNumber++] = newBooster;
		DeployBooster(boosterNumber, newBooster);
	}

	function setCryptoFlowLibAddress(address _cryptoFlowLibAddress) onlyOwner {
		cryptoFlowLibAddress = _cryptoFlowLibAddress;
	}

	function setChallengeLibAddress(address _challengeLibAddress) onlyOwner {
		challengeLibAddress = _challengeLibAddress;
	}

	function setDefendLibAddress(address _defendLibAddress) onlyOwner {
		defendLibAddress = _defendLibAddress;
	}
}

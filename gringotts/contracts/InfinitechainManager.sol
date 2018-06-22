pragma solidity ^0.4.23;

import "./Sidechain.sol";

contract InfinitechainManager {
	address public owner;
	address public cryptoFlowLibAddress;
	address public challengeLibAddress;
	uint256 public sidechainNumber;
	mapping (uint256 => address) public sidechainAddress;
	// id = 0, for ledger use

	event DeploySidechain(uint256 _sidechainId, address _sidechainAddress);

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

	function InfinitechainManager(address _cryptoFlowLibAddress, address _challengeLibAddress) {
		owner = msg.sender;
		cryptoFlowLibAddress = _cryptoFlowLibAddress;
		challengeLibAddress = _challengeLibAddress;
	}

	function deploySidechain(
		address _sidechainOwner,
		address[] _assetAddresses,
		uint256 _instantWithdrawMaximum
	) 
		onlyOwner 
	{
		address newSidechain = new Sidechain(_sidechainOwner, cryptoFlowLibAddress, challengeLibAddress, _assetAddresses, _instantWithdrawMaximum);
		sidechainAddress[sidechainNumber++] = newSidechain;
		DeploySidechain(sidechainNumber, newSidechain);
	}

	function setCryptoFlowLibAddress(address _cryptoFlowLibAddress) onlyOwner {
		cryptoFlowLibAddress = _cryptoFlowLibAddress;
	}

	function setChallengeLibAddress(address _challengeLibAddress) onlyOwner {
		challengeLibAddress = _challengeLibAddress;
	}
}

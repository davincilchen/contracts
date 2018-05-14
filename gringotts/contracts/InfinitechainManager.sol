pragma solidity ^0.4.23;

import "./Sidechain.sol";

contract InfinitechainManager {
	address public owner;
	address public sidechainLibAddress;
	uint256 public sidechainNumber;
	mapping (uint256 => address) public sidechainAddress;

	event DeploySidechain(uint256 _sidechainId, address _sidechainAddress);

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier sidechainExist(uint256 _sidechainId) {
    	require(_sidechainId <= sidechainNumber);
    	_;
    }

	function InfinitechainManager(address _sidechainLibAddress) {
		owner = msg.sender;
		sidechainLibAddress = _sidechainLibAddress;
		deploySidechain(owner);
	}

	function deploySidechain(address _sidechainOwner) onlyOwner {
		sidechainNumber++;
		address newSidechain = new Sidechain(_sidechainOwner, sidechainLibAddress);
		sidechainAddress[sidechainNumber] = newSidechain;
		DeploySidechain(sidechainNumber, newSidechain);
	}
}
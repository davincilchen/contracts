pragma solidity ^0.4.15;

import "./Sidechain.sol";

contract InfinitechainManager {
	address public owner;
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

	function InfinitechainManager() {
		owner = msg.sender;
	}

	function deploySidechain() onlyOwner {
		sidechainNumber++;
		address newSidechain = new Sidechain();
		sidechainAddress[sidechainNumber] = newSidechain;
		DeploySidechain(sidechainNumber, newSidechain);
	}

	function getStageHeight(uint256 _sidechainId) sidechainExist(_sidechainId) constant returns (uint256) {
		return Sidechain(sidechainAddress[_sidechainId]).getStageHeight();
	}
}
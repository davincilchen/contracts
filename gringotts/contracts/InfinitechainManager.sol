pragma solidity ^0.4.23;

import "./Sidechain.sol";

contract InfinitechainManager {
	address public owner;
	address public sidechainLibAddress;
	uint256 public sidechainNumber;
	mapping (uint256 => address) public sidechainAddress;
	// id = 0, for ledger use
	mapping (uint256 => address) public assetAddress;

	event DeploySidechain(uint256 _sidechainId, address _sidechainAddress);

	modifier onlyOwner {
        require(msg.sender == owner);
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

	function setAssetAddress(uint256 _assetID, address _tokenAddress) onlyOwner {
		require(_assetID != 0);
		assetAddress[_assetID] = _tokenAddress;
	}
}
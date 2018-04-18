pragma solidity ^0.4.15;

import "./SidechainLib.sol";

contract Sidechain {
	mapping (uint256 => SidechainLib.Stage) private stages;
	mapping (bytes32 => SidechainLib.Log) public logs;
	uint256 public stageHeight;
	address public owner;

	address public sidechainLibAddress;
	string public description;

	mapping (bytes32 => bytes4) public functionSig;

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier stageExist (uint256 _stageId) {
    	require(_stageId <= stageHeight);
    	_;
    }

    function Sidechain(address _sidechainLibAddress) {
    	owner = msg.sender;
    	sidechainLibAddress = _sidechainLibAddress;
    	description = "test";
    	stages[stageHeight].data = "genisis stage";
    	setFunctionSig('attachStage', 0x1655e8ac);
    	setFunctionSig('proposeDeposit', 0xdcf12aba);
    	setFunctionSig('deposit', 0x7b9d7d74);
    }

	function setFunctionSig(bytes32 _functionName, bytes4 _signature) onlyOwner {
		functionSig[_functionName] = _signature;
	}

    function delegateToLib(bytes32 _functionName, bytes32[] _parameter) payable {
        sidechainLibAddress.delegatecall( functionSig[_functionName], uint256(32), uint256(_parameter.length), _parameter);
    }

	function getStageHeight() constant returns (uint256) {
		return stageHeight;
	}
	
	function getStageInfo(uint256 _stageId) stageExist(_stageId) constant returns(bytes32, bytes32, bytes32, bytes32) {
		return 
		(
			stages[_stageId].stageHash,
			stages[_stageId].balanceRootHash,
			stages[_stageId].receiptRootHash,
			stages[_stageId].data
		);
	}
}
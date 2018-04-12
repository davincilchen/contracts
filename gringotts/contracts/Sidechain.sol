pragma solidity ^0.4.15;

import "./SidechainLib.sol";

contract Sidechain {
	address public owner;
	uint256 public stageHeight;
	uint256 public logNumber;
	mapping (uint256 => SidechainLib.Stage) private stages;
	mapping (uint256 => SidechainLib.Log) private logs;
	string public description;


	event ProposeDeposit (
		bytes32 _lightTxHash,
		string _type,
		address _client,
		uint256 _value,
		uint256 _fee,
		uint256 _lsn,
		uint256 _stageHeight,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	);

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier stageExist (uint256 _stageId) {
    	require(_stageId <= stageHeight);
    	_;
    }

    function Sidechain() {
    	owner = msg.sender;
    	description = "test";
    	stages[stageHeight].data = "genisis stage";
    }

    function attachStage(
		bytes32 _balanceRootHash,
		bytes32 _receiptRootHash,
		string _data
	) 
		onlyOwner
	{ 
		stageHeight++;
		stages[stageHeight].balanceRootHash = _balanceRootHash;
		stages[stageHeight].receiptRootHash = _receiptRootHash;
		stages[stageHeight].data = _data;
	}

	function proposeDeposit(
		bytes32 _lightTxHash, 
		uint256 _fee,
		uint256 _lsn,
		uint8 _v,
		bytes32 _r,
		bytes32 _s

	) 
		payable 
	{
		ProposeDeposit ( _lightTxHash,"deposit", msg.sender, msg.value, _fee, _lsn, stageHeight+1, _v, _r, _s );
		logNumber++;
		logs[logNumber].stageHeight = stageHeight+1;
		logs[logNumber].lsn = _lsn;
		logs[logNumber].client = msg.sender;
		logs[logNumber].value = msg.value;
		logs[logNumber].flagDeposit = false;
	}

	function deposit (
		uint256 _gsn,
		bytes32 _lightTxHash,
		uint256 _fromBalance,
		uint256 _toBalance,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) 
		//onlyOwner
	{

	}

	function getStageHeight() constant returns (uint256) {
		return stageHeight;
	}
	
	function getStageInfo(uint256 _stageId) stageExist(_stageId) constant returns(bytes32, bytes32, bytes32, string) {
		return 
		(
			stages[_stageId].stageHash,
			stages[_stageId].balanceRootHash,
			stages[_stageId].receiptRootHash,
			stages[_stageId].data
		);
	}
}
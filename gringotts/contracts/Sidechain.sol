pragma solidity ^0.4.15;

import "./SidechainLib.sol";

contract Sidechain {
	mapping (uint256 => SidechainLib.Stage) public stages;
	mapping (bytes32 => SidechainLib.Log) public logs;
	uint256 public stageHeight;
	address public owner;

	address public sidechainLibAddress;
	string public description;

    event ProposeDeposit (
        bytes32 _lightTxHash,
        bytes32 _client,
        bytes32 _value,
        bytes32 _fee,
        bytes32 _lsn,
        bytes32 _stageHeight,
        bytes32 _v,
        bytes32 _r,
        bytes32 _s
    );

    event Deposit (
        bytes32 _gsn,
        bytes32 _lightTxHash,
        bytes32 _fromBalance,
        bytes32 _toBalance
    );

    function Sidechain(address _sidechainOwner, address _sidechainLibAddress) {
    	owner = _sidechainOwner;
    	sidechainLibAddress = _sidechainLibAddress;
    	description = "test";
    	stages[stageHeight].data = "genisis stage";
    }

    function delegateToLib(bytes4 _signature, bytes32[] _parameter) payable {
    	/*
     	'attachStage(bytes32[])':    0x1655e8ac
    	'proposeDeposit(bytes32[])': 0xdcf12aba
    	'deposit(bytes32[])':        0x7b9d7d74
    	*/
        sidechainLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }
}
pragma solidity ^0.4.23;

import "./Util.sol";

contract ChallengedLib {
    mapping (address => bool) public assetAddresses;
    uint256 public stageHeight;
    uint256 public instantWithdrawMaximum;
    uint256 public depositSequenceNumber;
    address public owner;
    
    mapping (uint256 => ChallengedLib.Stage) public stages;
    address public utilAddress;
    string constant version = "v1.3.0";

    struct Stage {
        bytes32 receiptRootHash;
        bytes32 accountRootHash;
		bytes32 data;
	    mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedList;
        bytes32[] challengedLightTxHashes;	
	}

    struct ChallengedInfo {
        address client;
        bool challengedState;
        bool getCompensation;
    }

    event Attach (
        bytes32 _stageHeight,
        bytes32 _receiptRootHash,
        bytes32 _accountRootHash
    );
    
    event Challenge (
        bytes32 _client,
        bytes32 _lightTxHash
    );
    
    function ChallengedLib (address _utilAddress) {
        utilAddress = _utilAddress;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function attach (bytes32[] _parameter) {
        /*
        _parameter[0] = _receiptRootHash
        _parameter[1] = _accountRootHash
        _parameter[2] = _data
        */
        stageHeight++;
        stages[stageHeight].receiptRootHash = _parameter[0];
        stages[stageHeight].accountRootHash = _parameter[1];
        stages[stageHeight].data = _parameter[2];
        emit Attach (bytes32(stageHeight), _parameter[0], _parameter[1]);
    }
    
    function challenge (bytes32[] _parameter) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash,
        parameter[2] = _v,
        parameter[3] = _r,
        parameter[4] = _s
        */
        require (_parameter.length == 5);
        address signer = Util(utilAddress).verify(_parameter[1], uint8(_parameter[2]), _parameter[3], _parameter[4]);
        require (signer == msg.sender);
        stages[uint256(_parameter[0])].challengedList[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (bytes32(msg.sender), _parameter[1]);
    }

    function getChallengedHash (bytes32[] _parameter) constant returns (bytes32) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _challengeNumber
        */
        return stages[uint256(_parameter[0])].challengedLightTxHashes[uint256(_parameter[1])];
    }
    
    function getChallengedInfo (bytes32[] _parameter) constant returns (address, bool, bool) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash
        */
        return (stages[uint256(_parameter[0])].challengedList[_parameter[1]].client, stages[uint256(_parameter[0])].challengedList[_parameter[1]].challengedState, stages[uint256(_parameter[0])].challengedList[_parameter[1]].getCompensation);
    }
}

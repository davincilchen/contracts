pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";

contract Sidechain {
    mapping (address => bool) public assetAddresses;
    uint256 public stageHeight;
    uint256 public instantWithdrawMaximum;
    uint256 public depositSequenceNumber;
    address public owner;

    address public managerAddress;
    address public cryptoFlowLibAddress;
    address public challengedLibAddress;
    mapping (uint256 => ChallengedLib.Stage) public stages;
    mapping (bytes32 => CryptoFlowLib.Log) public depositLogs;
    mapping (bytes32 => CryptoFlowLib.Log) public withdrawalLogs;

    event ProposeDeposit (
        bytes32 indexed _dsn,
        bytes32 _client,
        bytes32 _value
    );

    event VerifyReceipt (
        uint256 indexed _type, // { 0: deposit, 1: proposeWithdrawal, 2: instantWithdraw}
        bytes32 _gsn,
        bytes32 _lightTxHash,
        bytes32 _fromBalance,
        bytes32 _toBalance,
        bytes32[3] _sigLightTx,
        bytes32[3] _sigReceipt
    );

    event Withdraw (
        bytes32 indexed _wsn,
        bytes32 _client,
        bytes32 _value
    );

    event Attach (
        bytes32 _stageHeight,
        bytes32 _receiptRootHash,
        bytes32 _accountRootHash
    );

    event Challenge (
        bytes32 _client,
        bytes32 _lightTxHash
    );

    function Sidechain (
        address _sidechainOwner,
        address _cryptoFlowLibAddress,
        address _challengedLibAddress,
        address[] _assetAddresses,
        uint256 _instantWithdrawMaximum
    ) {
        managerAddress = msg.sender;
        owner = _sidechainOwner;
        cryptoFlowLibAddress = _cryptoFlowLibAddress;
        challengedLibAddress = _challengedLibAddress;
        instantWithdrawMaximum = _instantWithdrawMaximum;
        stages[stageHeight].data = "genisis stage";
        
        for (uint i=0; i<_assetAddresses.length; i++) {
            assetAddresses[_assetAddresses[i]] = true;
        }
    }

    function delegateToCryptoFlow (bytes4 _signature, bytes32[] _parameter) payable {
        /*
        'proposeDeposit(bytes32[])':     0xdcf12aba
        'deposit(bytes32[])':            0x7b9d7d74
        'proposeWithdrawal(bytes32[])':  0x68ff1929
        'withdraw(bytes32[])':           0xfe2b3924
        'instantWithdraw(bytes32[])':    0xbe1946da
        */
        cryptoFlowLibAddress.delegatecall( _signature, _parameter);
    }

    function delegateToChallenge (bytes4 _signature, bytes32[] _parameter) public {
        /*
        'challenge(bytes32[])':          0x31c915b4
        'attach(bytes32[])':             0x95aa4aac
        */
        
        challengedLibAddress.delegatecall( _signature, _parameter);
    }
    
    function challenge (bytes32[] _parameter) public {
        ChallengedLib(challengedLibAddress).challenge(_parameter);
    }

    function () payable {
        /*
        called delegateToLib to 'proposeDeposit(bytes32[])'
        gas used : 127075
        gad used : 106627
        suggested gas : 150000
        */
        bytes32[] memory bytes32Array = new bytes32[](2);
        bytes32Array[0] = bytes32(msg.sender);
        bytes32Array[1] = bytes32(msg.value);
        delegateToCryptoFlow(0xdcf12aba, bytes32Array);
    }

    function setAssetAddress(address asAddress) {
        assetAddresses[asAddress] = true;
    }

    function unsetAssetAddress(address asAddress) {
        delete assetAddresses[asAddress];
    }

    function tokenFallback(address _from, uint _value) public returns (bool success) {
        if(assetAddresses[msg.sender] == false) {
            revert();
        } else {
            bytes32[] memory bytes32Array = new bytes32[](2);
            bytes32Array[0] = bytes32(_from);
            bytes32Array[1] = bytes32(_value);
            delegateToCryptoFlow(0xdcf12aba, bytes32Array);
            return true;
        }
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

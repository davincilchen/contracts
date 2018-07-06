pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./DefendLib.sol";
import "./Util.sol";

contract Sidechain {
    mapping (address => bool) public assetAddresses;
    uint256 public stageHeight;
    uint256 public instantWithdrawMaximum;
    uint256 public depositSequenceNumber;
    address public owner;

    address public utilAddress;
    address public managerAddress;
    address public cryptoFlowLibAddress;
    address public challengedLibAddress;
    address public defendLibAddress;
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
        uint256 indexed _challengedType, // { type: 1 - 4, 1: repeatedGSN 2: wrongBalance 3: skippedGSN 4: existProof }
        bytes32 _client,
        bytes32 _lightTxHash
    );

    event Defend (
        bytes32 _lightTxHash,
        bool _challengeState
    );

    function Sidechain (
        address _sidechainOwner,
        address _utilAddress,
        address _cryptoFlowLibAddress,
        address _challengedLibAddress,
        address _defendLibAddress,
        address[] _assetAddresses,
        uint256 _instantWithdrawMaximum
    ) {
        managerAddress = msg.sender;
        owner = _sidechainOwner;
        utilAddress = _utilAddress;
        cryptoFlowLibAddress = _cryptoFlowLibAddress;
        challengedLibAddress = _challengedLibAddress;
        defendLibAddress = _defendLibAddress;
        instantWithdrawMaximum = _instantWithdrawMaximum;
        stages[stageHeight].data = "genisis stage";
        
        for (uint i=0; i<_assetAddresses.length; i++) {
            assetAddresses[_assetAddresses[i]] = true;
        }
    }

    function delegateToCryptoFlowLib (bytes4 _signature, bytes32[] _parameter) payable {
        /*
        'proposeDeposit(bytes32[])':     0xdcf12aba
        'deposit(bytes32[])':            0x7b9d7d74
        'proposeWithdrawal(bytes32[])':  0x68ff1929
        'withdraw(bytes32[])':           0xfe2b3924
        'instantWithdraw(bytes32[])':    0xbe1946da
        */
        cryptoFlowLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }

    function delegateToChallengedLib (bytes4 _signature, bytes32[] _parameter) public {
        /*
        'attach(bytes32[])':                                0x95aa4aac
        'challengedRepeatedGSN(bytes32[])':                 0xb210ffbf
        'challengedWrongBalance(bytes32[])':                0x4259ee16
        'challengedSkippedGSN(bytes32[])':                  0x6f62a2d9
        'challengedExistedProof(bytes32[])':                0xbfe6f0e2
        */
        challengedLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }

    function delegateToDefendLib (bytes4 _signature, bytes32[] _parameter) public {
        /*
        'defendWrongBalances(bytes32[])':                    0xa2e630a5
        'defendSkippedGSN(bytes32[])':                       0xdc64db7c
        'defendExistProof(bytes32[])':                       0xe1e59fb4
        */
        defendLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
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
        delegateToCryptoFlowLib(0xdcf12aba, bytes32Array);
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
            delegateToCryptoFlowLib(0xdcf12aba, bytes32Array);
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

    function getChallengedRepeatedGSNListInfo (bytes32[] _parameter) constant returns (address, bytes32, bytes32, bool, bool) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash
        */
        return (stages[uint256(_parameter[0])].challengedRepeatedGSNList[_parameter[1]].client, stages[uint256(_parameter[0])].challengedRepeatedGSNList[_parameter[1]].lightTxHashes[0], stages[uint256(_parameter[0])].challengedRepeatedGSNList[_parameter[1]].lightTxHashes[1], stages[uint256(_parameter[0])].challengedRepeatedGSNList[_parameter[1]].challengedState, stages[uint256(_parameter[0])].challengedRepeatedGSNList[_parameter[1]].getCompensation);
    }

    function getChallengedWrongBalanceListInfo (bytes32[] _parameter) constant returns (address, bytes32, bytes32, bool, bool) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash
        */
        return (stages[uint256(_parameter[0])].challengedWrongBalanceList[_parameter[1]].client, stages[uint256(_parameter[0])].challengedWrongBalanceList[_parameter[1]].lightTxHashes[0], stages[uint256(_parameter[0])].challengedWrongBalanceList[_parameter[1]].lightTxHashes[1], stages[uint256(_parameter[0])].challengedWrongBalanceList[_parameter[1]].challengedState, stages[uint256(_parameter[0])].challengedWrongBalanceList[_parameter[1]].getCompensation);
    }

    function getChallengedSkippedGSNListInfo (bytes32[] _parameter) constant returns (address, bytes32, bytes32, bool, bool) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash
        */
        return (stages[uint256(_parameter[0])].challengedSkippedGSNList[_parameter[1]].client, stages[uint256(_parameter[0])].challengedSkippedGSNList[_parameter[1]].lightTxHashes[0], stages[uint256(_parameter[0])].challengedSkippedGSNList[_parameter[1]].lightTxHashes[1], stages[uint256(_parameter[0])].challengedSkippedGSNList[_parameter[1]].challengedState, stages[uint256(_parameter[0])].challengedSkippedGSNList[_parameter[1]].getCompensation);
    }

    function getChallengedExistedProofListInfo (bytes32[] _parameter) constant returns (address, bytes32, bytes32, bool, bool) {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash
        */
        return (stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[1]].client, stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[1]].lightTxHashes[0], stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[1]].lightTxHashes[1], stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[1]].challengedState, stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[1]].getCompensation);
    }
}

pragma solidity ^0.4.23;

import "./SidechainLib.sol";

contract Sidechain {
    mapping (uint256 => SidechainLib.Stage) public stages;
    mapping (bytes32 => SidechainLib.Log) public depositLogs;
    mapping (bytes32 => SidechainLib.Log) public withdrawalLogs;
    mapping (address => bool) public assetAddresses;
    uint256 public stageHeight;
    uint256 public instantWithdrawMaximum;
    uint256 public depositSequenceNumber;
    address public owner;

    address public managerAddress;
    address public sidechainLibAddress;

    event ProposeDeposit (
        bytes32 indexed _dsn,
        bytes32 indexed _client,
        bytes32 _value,
        bytes32 _assetID
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

    event Attach (
        bytes32 _stageHeight,
        bytes32 _receiptRootHash,
        bytes32 _accountRootHash
    );

    event Withdraw (
        bytes32 indexed _wsn,
        bytes32 indexed _client,
        bytes32 _value,
        bytes32 _assetID
    );

    function Sidechain (
        address _sidechainOwner,
        address _sidechainLibAddress,
        address[] _assetAddresses,
        uint256 _instantWithdrawMaximum
    ) {
        managerAddress = msg.sender;
        owner = _sidechainOwner;
        sidechainLibAddress = _sidechainLibAddress;
        instantWithdrawMaximum = _instantWithdrawMaximum;
        stages[stageHeight].data = "genisis stage";
        
        for (uint i=0; i<_assetAddresses.length; i++) {
            assetAddresses[_assetAddresses[i]] = true;
        }
    }

    function delegateToLib (bytes4 _signature, bytes32[] _parameter) payable {
        /*
        'attach(bytes32[])':             0x95aa4aac
        'proposeDeposit(bytes32[])':     0xdcf12aba
        'deposit(bytes32[])':            0x7b9d7d74
        'proposeWithdrawal(bytes32[])':  0x68ff1929
        'withdraw(bytes32[])':           0xfe2b3924
        'instantWithdraw(bytes32[])':    0xbe1946da
        */
        sidechainLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }

    function () payable {
        /*
        called delegateToLib to 'proposeDeposit(bytes32[])'
        gas used : 127075
        gad used : 106627
        suggested gas : 150000
        */
        bytes32[] memory bytes32Array = new bytes32[](3);
        bytes32Array[0] = bytes32(msg.sender);
        bytes32Array[1] = bytes32(msg.value);
        bytes32Array[2] = bytes32(0);
        delegateToLib(0xdcf12aba, bytes32Array);
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
            bytes32[] memory bytes32Array = new bytes32[](3);
            bytes32Array[0] = bytes32(_from);
            bytes32Array[1] = bytes32(_value);
            bytes32Array[2] = bytes32(msg.sender);
            delegateToLib(0xdcf12aba, bytes32Array);
            return true;
        }
    }
}

pragma solidity ^0.4.23;

import "./SidechainLib.sol";

contract Sidechain {
    mapping (uint256 => SidechainLib.Stage) public stages;
    mapping (uint256 => SidechainLib.DepositLog) public depositLogs;
    mapping (bytes32 => SidechainLib.Log) public logs;
    uint256 public stageHeight;
    address public owner;

    address public sidechainLibAddress;
    uint256 public depositSequenceNumber;
    string public description;

    event ProposeDeposit (
        uint256 indexed dsn,
        address client,
        uint256 value
    );

    event VerifyReceipt (
        uint256 indexed _type, // {0: deposit, 1: withdrawal, 2: instantWithdrawal}
        bytes32 _stageHeight,
        bytes32 _gsn,
        bytes32 _lightTxHash,
        bytes32 _fromBalance,
        bytes32 _toBalance,
        bytes32[3] _sig_receipt,
        bytes32[3] _sig_lightTx
    );

    event AttachStage (
        bytes32 _stageHeight,
        bytes32 _receiptRootHash,
        bytes32 _balanceRootHash
    );

    function Sidechain (address _sidechainOwner, address _sidechainLibAddress) {
        owner = _sidechainOwner;
        sidechainLibAddress = _sidechainLibAddress;
        description = "test";
        stages[stageHeight].data = "genisis stage";
    }

    function delegateToLib (bytes4 _signature, bytes32[] _parameter) payable {
        /*
        'attachStage(bytes32[])':        0x1655e8ac
        'proposeDeposit(bytes32[])':     0xdcf12aba
        'deposit(bytes32[])':            0x7b9d7d74
        'proposeWithdrawal(bytes32[])':  0x68ff1929
        'confirmWithdrawal(bytes32[])':  0xe0671980
        'withdraw(bytes32[])':           0xfe2b3924
        'instantWithdraw(bytes32[])':    0xbe1946da
        */
        sidechainLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }

    function () payable {
        /*
        called delegateToLib to 'proposeDeposit(bytes32[])'
        gas used : 91404
        suggested gas : 100000
        */
        bytes32[] memory bytes32Array = new bytes32[](3);
        bytes32Array[0] = bytes32(depositSequenceNumber);
        bytes32Array[1] = bytes32(msg.sender);
        bytes32Array[2] = bytes32(msg.value);
        delegateToLib(0xdcf12aba, bytes32Array);
        depositSequenceNumber++;
    }
}

pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./Util.sol";

contract Token {
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract CryptoFlowLib {
    mapping (address => bool) public assetAddresses;
    uint256 public stageHeight;
    uint256 public instantWithdrawMaximum;
    uint256 public depositSequenceNumber;
    address public owner;
    
    address public utilAddress;
    address public managerAddress;
    address public cryptoFlowLibAddress;
    address public challengedLibAddress;
    mapping (uint256 => ChallengedLib.Stage) public stages;
    mapping (bytes32 => CryptoFlowLib.Log) public depositLogs;
    mapping (bytes32 => CryptoFlowLib.Log) public withdrawalLogs;

    struct Log {
        bytes32 stage;
        bytes32 client;
        bytes32 value;
        bool flag;
    }

    event ProposeDeposit (
        bytes32 indexed _dsn,
        bytes32 _client,
        bytes32 _value
    );

    event VerifyReceipt (
        uint256 indexed _type, // { 0: deposit, 1: proposeWithdrawal, 2: instantWithdrawal }
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

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isSigValid (bytes32[] _parameter) {
        /*
        _parameter[0] = _lightTxHash

        ===lightTxData===
        _parameter[1] = _from
        _parameter[2] = _to
        _parameter[3] = _assetID
        _parameter[4] = _value
        _parameter[5] = _fee
        _parameter[6] = _nonce
        _parameter[7] = _logID
        _parameter[8] = _metadataHash

        ===clientLtxSignature===
        _parameter[9] = _vFromClient
        _parameter[10] = _rFromClient
        _parameter[11] = _sFromClient

        ===receipt===
        _parameter[12] = _gsn,
        _parameter[13] = _fromBalance,
        _parameter[14] = _toBalance,

        ===serverLtxSignature===
        _parameter[15] = _vFromServer
        _parameter[16] = _rFromServer
        _parameter[17] = _sFromServer

        ===serverReceiptSignature===
        _parameter[18] = _vFromServer,
        _parameter[19] = _rFromServer,
        _parameter[20] = _sFromServer,

        */
        bytes32[] memory bytes32Array = new bytes32[](8);
        bytes32Array[0] = _parameter[1]; // from
        bytes32Array[1] = _parameter[2]; // to
        bytes32Array[2] = _parameter[3]; // assetID
        bytes32Array[3] = _parameter[4]; // value
        bytes32Array[4] = _parameter[5]; // fee
        bytes32Array[5] = _parameter[6]; // nonce
        bytes32Array[6] = _parameter[7]; // logID
        bytes32Array[7] = _parameter[8]; // metadataHash
        bytes32 hashMsg = Util(utilAddress).hashArray(bytes32Array);
        require(hashMsg == _parameter[0]);
        address signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[9]), _parameter[10], _parameter[11]);
        if (address(0) == address(_parameter[1]) && address(0) != address(_parameter[2])) {
            // Deposit
            require(signer == address(_parameter[2]));
            require(signer == address(depositLogs[_parameter[7]].client));
            require(_parameter[4] == depositLogs[_parameter[7]].value);
        } else if (address(0) != address(_parameter[1]) && address(0) == address(_parameter[2])) {
            // Withdraw
            require(signer == address(_parameter[1]));
        } else {
            revert();
        }

        bytes32Array = new bytes32[](5);
        bytes32Array[0] = bytes32(stageHeight+1); // stageHeight
        bytes32Array[1] = _parameter[12];         // gsn
        bytes32Array[2] = _parameter[0];          // lightTxHash
        bytes32Array[3] = _parameter[13];         // fromBalance
        bytes32Array[4] = _parameter[14];         // toBalance
        hashMsg = Util(utilAddress).hashArray(bytes32Array);
        signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[18]), _parameter[19], _parameter[20]);
        require (signer == owner);
        _;
    }

    function proposeDeposit (bytes32[] _parameter) payable {
        /*
        _parameter[0] = client
        _parameter[1] = value
        */
        bytes32 dsn = bytes32(depositSequenceNumber);
        depositLogs[dsn].stage = bytes32(stageHeight + 1);
        depositLogs[dsn].client = _parameter[0];
        depositLogs[dsn].value = _parameter[1];
        depositSequenceNumber++;

        emit ProposeDeposit (dsn, _parameter[0], _parameter[1]);
    }

    function deposit (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        depositLogs[_parameter[7]].flag = true;

        emit VerifyReceipt ( 0,
                             _parameter[12],
                             _parameter[0],
                             _parameter[13],
                             _parameter[14],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]],
                             [ _parameter[18],
                               _parameter[19],
                               _parameter[20]]);
    }

    function proposeWithdrawal (bytes32[] _parameter) isSigValid (_parameter) public {
        /*
        wsn = concat(from + nonce)
        */
        bytes32[] memory bytes32Array = new bytes32[](2);
        bytes32Array[0] = _parameter[1]; // from
        bytes32Array[1] = _parameter[6]; // nonce
        bytes32 wsn = Util(utilAddress).hashArray(bytes32Array);

        withdrawalLogs[wsn].stage = bytes32(stageHeight+1);
        withdrawalLogs[wsn].client = _parameter[1];
        withdrawalLogs[wsn].value = bytes32(uint256(_parameter[4]) - uint256(_parameter[5])); // value - fee

        emit VerifyReceipt ( 1,
                             _parameter[12],
                             _parameter[0],
                             _parameter[13],
                             _parameter[14],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]],
                             [ _parameter[18],
                               _parameter[19],
                               _parameter[20]]);
    }

    function withdraw (bytes32[] _parameter) public {
        /*
        _parameter[0] = _wsn
        */
        // flag = false
        require(!withdrawalLogs[_parameter[0]].flag);
        // over challenge time
        require (uint256(withdrawalLogs[_parameter[0]].stage) < stageHeight);
        address client = address(withdrawalLogs[_parameter[0]].client);
        uint256 value = uint256(withdrawalLogs[_parameter[0]].value);
        address assetAddress = address(_parameter[3]);
        if (assetAddresses[assetAddress] != false) {
            Token(assetAddress).transfer(client, value);
        } else {
            client.transfer(value);
            withdrawalLogs[_parameter[0]].flag = true;
        }
        emit Withdraw (_parameter[0], bytes32(client), bytes32(value));
    }

    function instantWithdraw (bytes32[] _parameter) isSigValid (_parameter) public {
        // instantWithdraw condition
        require (uint256(_parameter[4]) <= instantWithdrawMaximum);
        /*
        wsn = concat(from + nonce)
        */
        bytes32[] memory bytes32Array = new bytes32[](2);
        bytes32Array[0] = _parameter[1]; // from
        bytes32Array[1] = _parameter[6]; // nonce
        bytes32 wsn = Util(utilAddress).hashArray(bytes32Array);

        require(withdrawalLogs[wsn].flag == false);
        withdrawalLogs[wsn].stage = bytes32(stageHeight+1);
        withdrawalLogs[wsn].client = _parameter[1];
        withdrawalLogs[wsn].value = _parameter[4];
        withdrawalLogs[wsn].flag = true;

        if (assetAddresses[address(_parameter[3])] != false) {
            Token(address(_parameter[3])).transfer(address(_parameter[2]), uint256(_parameter[4]));
        } else {
            address(_parameter[1]).transfer(uint256(_parameter[4]));
        }

        emit VerifyReceipt ( 2,
                             _parameter[12],
                             _parameter[0],
                             _parameter[13],
                             _parameter[14],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]],
                             [ _parameter[18],
                               _parameter[19],
                               _parameter[20]]);
    }
}

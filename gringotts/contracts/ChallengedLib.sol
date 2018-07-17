pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./DefendLib.sol";
import "./Util.sol";
import "./EIP20/SafeMath.sol";

contract ChallengedLib {
    using SafeMath for uint256;
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

    struct Stage {
        bytes32 receiptRootHash;
        bytes32 accountRootHash;
        bytes32 data;
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedRepeatedGSNList;// repeated gsn
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedWrongBalanceList;// wrong balance
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedSkippedGSNList;// skipped gsn
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedExistedProofList;// exitsProof
        bytes32[] challengedLightTxHashes;	
	}

    struct ChallengedInfo {
        address client;
        bytes32[2] lightTxHashes;
        bool challengedState;
        bool getCompensation;
    }

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

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier isSigValid (bytes32[] _parameter) {
        /*
        =============================Receipt1=======================================
        _parameter[0] = _lightTxHash

        ===lightTxData===
        _parameter[1] = _from
        _parameter[2] = _to
        _parameter[3] = _assetID
        _parameter[4] = _value
        _parameter[5] = _fee
        _parameter[6] = _nonce
        _parameter[7] = _logID
        _parameter[8] = _clientMetadataHash

        ===clientLtxSignature===
        _parameter[9] = _vFromClient
        _parameter[10] = _rFromClient
        _parameter[11] = _sFromClient

        ===receiptData===
        _parameter[12] = _stageHeight
        _parameter[13] = _gsn
        _parameter[14] = _fromBalance
        _parameter[15] = _toBalance
        _parameter[16] = _serverMetadataHash

        ===serverLtxSignature===
        _parameter[17] = _vFromServer
        _parameter[18] = _rFromServer
        _parameter[19] = _sFromServer

        ===serverReceiptSignature===
        _parameter[20] = _vFromServer
        _parameter[21] = _rFromServer
        _parameter[22] = _sFromServer
        */

        bytes32[] memory bytes32Array = new bytes32[](8);
        bytes32Array[0] = _parameter[1]; // from
        bytes32Array[1] = _parameter[2]; // to
        bytes32Array[2] = _parameter[3]; // assetID
        bytes32Array[3] = _parameter[4]; // value
        bytes32Array[4] = _parameter[5]; // fee
        bytes32Array[5] = _parameter[6]; // nonce
        bytes32Array[6] = _parameter[7]; // logID
        bytes32Array[7] = _parameter[8]; // clientMetadataHash
        bytes32 hashMsg = Util(utilAddress).hashArray(bytes32Array);
        require(hashMsg == _parameter[0]);
        address signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[9]), _parameter[10], _parameter[11]);
        bytes32Array = new bytes32[](6);
        bytes32Array[0] = _parameter[12]; // stageHeight
        bytes32Array[1] = _parameter[13]; // gsn
        bytes32Array[2] = _parameter[0];  // lightTxHash
        bytes32Array[3] = _parameter[14]; // fromBalance
        bytes32Array[4] = _parameter[15]; // toBalance
        bytes32Array[5] = _parameter[16]; // serverMetadata
        hashMsg = Util(utilAddress).hashArray(bytes32Array);
        signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[20]), _parameter[21], _parameter[22]);
        require (signer == owner);
        _;

        /*
        =============================Receipt2=======================================
        _parameter[23] = _lightTxHash

        ===lightTxData===
        _parameter[24] = _from
        _parameter[25] = _to
        _parameter[26] = _assetID
        _parameter[27] = _value
        _parameter[28] = _fee
        _parameter[29] = _nonce
        _parameter[30] = _logID
        _parameter[31] = clientMetadataHash

        ===clientLtxSignature===
        _parameter[32] = _vFromClient
        _parameter[33] = _rFromClient
        _parameter[34] = _sFromClient

        ===receiptData===
        _parameter[35] = _stageHeight
        _parameter[36] = _gsn
        _parameter[37] = _fromBalance
        _parameter[38] = _toBalance
        _parameter[39] = _serverMetadataHash
        ===serverLtxSignature===
        _parameter[40] = _vFromServer
        _parameter[41] = _rFromServer
        _parameter[42] = _sFromServer

        ===serverReceiptSignature===
        _parameter[43] = _vFromServer
        _parameter[44] = _rFromServer
        _parameter[45] = _sFromServer
        */
        if (_parameter.length == 44) {
            bytes32Array = new bytes32[](8);
            bytes32Array[0] = _parameter[24]; // from
            bytes32Array[1] = _parameter[25]; // to
            bytes32Array[2] = _parameter[26]; // assetID
            bytes32Array[3] = _parameter[27]; // value
            bytes32Array[4] = _parameter[28]; // fee
            bytes32Array[5] = _parameter[29]; // nonce
            bytes32Array[6] = _parameter[30]; // logID
            bytes32Array[7] = _parameter[31]; // clientMetadataHash
            hashMsg = Util(utilAddress).hashArray(bytes32Array);
            require(hashMsg == _parameter[23]);
            signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[32]), _parameter[33], _parameter[34]);
            bytes32Array = new bytes32[](6);
            bytes32Array[0] = _parameter[34]; // stageHeight
            bytes32Array[1] = _parameter[35]; // gsn
            bytes32Array[2] = _parameter[22]; // lightTxHash
            bytes32Array[3] = _parameter[36]; // fromBalance
            bytes32Array[4] = _parameter[37]; // toBalance
            bytes32Array[5] = _parameter[38]; // serverMetadataHash
            hashMsg = Util(utilAddress).hashArray(bytes32Array);
            signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[43]), _parameter[44], _parameter[45]);
            require (signer == owner);
            _;
        }
    }
    
    function attach (bytes32[] _parameter) public onlyOwner {
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
    
    function challengedRepeatedGSN (bytes32[] _parameter) isSigValid (_parameter) public {
        require (uint256(_parameter[13]) == uint256(_parameter[36]));// compare gsn
        stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
        stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
        emit Challenge (1, bytes32(msg.sender), _parameter[23]);
    }

    function challengedWrongBalance (bytes32[] _parameter) isSigValid (_parameter) public {
        if (address(_parameter[24]) == address(_parameter[1])) {
            if ((uint256(_parameter[37]).add(uint256(_parameter[27]))) != uint256(_parameter[14])) {
                stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
                stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
                emit Challenge (2, bytes32(msg.sender), _parameter[23]);
            }
        } else if (address(_parameter[24]) == address(_parameter[2])) {
            if ((uint256(_parameter[37]).add(uint256(_parameter[27]))) != uint256(_parameter[15])) {
                stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
                stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
                emit Challenge (2, bytes32(msg.sender), _parameter[23]);
            }
        } else if (address(_parameter[25]) == address(_parameter[1])) {
            if ((uint256(_parameter[37]).sub(uint256(_parameter[27]))) != uint256(_parameter[14])) {
                stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
                stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
                emit Challenge (2, bytes32(msg.sender), _parameter[23]);
            }
        } else if (address(_parameter[25]) == address(_parameter[2])) {
            if ((uint256(_parameter[37]).sub(uint256(_parameter[27]))) != uint256(_parameter[15])) {
                stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
                stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
                emit Challenge (2, bytes32(msg.sender), _parameter[23]);
            }
        }
    }

    function challengedSkippedGSN (bytes32[] _parameter) isSigValid (_parameter) public {
        require (uint256(_parameter[36]).sub(uint256(_parameter[13])) != 1);
        stages[uint256(_parameter[12])].challengedSkippedGSNList[_parameter[23]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], _parameter[23]], true, false);
        stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[23]);
        emit Challenge (3, bytes32(msg.sender), _parameter[23]);
    }

    // function challengedExistedProof (bytes32[] _parameter) isSigValid (_parameter) public {
    //     stages[uint256(_parameter[12])].challengedExistedProofList[_parameter[0]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[0], 0x0], true, false);
    //     stages[uint256(_parameter[12])].challengedLightTxHashes.push(_parameter[0]);
    //     emit Challenge (4, bytes32(msg.sender), _parameter[0]);
    // }
}

pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./DefendLib.sol";
import "./Util.sol";

contract DefendLib {
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

    event Defend (
        bytes32 _lightTxHash,
        bool _challengeState
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
        _parameter[8] = _metadataHash

        ===clientLtxSignature===
        _parameter[9] = _vFromClient
        _parameter[10] = _rFromClient
        _parameter[11] = _sFromClient

        ===receiptData===
        _parameter[12] = _stageHeight
        _parameter[13] = _gsn
        _parameter[14] = _fromBalance
        _parameter[15] = _toBalance

        ===serverLtxSignature===
        _parameter[16] = _vFromServer
        _parameter[17] = _rFromServer
        _parameter[18] = _sFromServer

        ===serverReceiptSignature===
        _parameter[19] = _vFromServer
        _parameter[20] = _rFromServer
        _parameter[21] = _sFromServer
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
        bytes32Array = new bytes32[](5);
        bytes32Array[0] = _parameter[12]; // stageHeight
        bytes32Array[1] = _parameter[13]; // gsn
        bytes32Array[2] = _parameter[0];  // lightTxHash
        bytes32Array[3] = _parameter[14]; // fromBalance
        bytes32Array[4] = _parameter[15]; // toBalance
        hashMsg = Util(utilAddress).hashArray(bytes32Array);
        signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[19]), _parameter[20], _parameter[21]);
        require (signer == owner);
        _;

        /*
        =============================Receipt2=======================================
        _parameter[22] = _lightTxHash

        ===lightTxData===
        _parameter[23] = _from
        _parameter[24] = _to
        _parameter[25] = _assetID
        _parameter[26] = _value
        _parameter[27] = _fee
        _parameter[28] = _nonce
        _parameter[29] = _logID
        _parameter[30] = _metadataHash

        ===clientLtxSignature===
        _parameter[31] = _vFromClient
        _parameter[32] = _rFromClient
        _parameter[33] = _sFromClient

        ===receiptData===
        _parameter[34] = _stageHeight
        _parameter[35] = _gsn
        _parameter[36] = _fromBalance
        _parameter[37] = _toBalance

        ===serverLtxSignature===
        _parameter[38] = _vFromServer
        _parameter[39] = _rFromServer
        _parameter[40] = _sFromServer

        ===serverReceiptSignature===
        _parameter[41] = _vFromServer
        _parameter[42] = _rFromServer
        _parameter[43] = _sFromServer
        */
        bytes32Array = new bytes32[](8);
        bytes32Array[0] = _parameter[23]; // from
        bytes32Array[1] = _parameter[24]; // to
        bytes32Array[2] = _parameter[25]; // assetID
        bytes32Array[3] = _parameter[26]; // value
        bytes32Array[4] = _parameter[27]; // fee
        bytes32Array[5] = _parameter[28]; // nonce
        bytes32Array[6] = _parameter[29]; // logID
        bytes32Array[7] = _parameter[30]; // metadataHash
        hashMsg = Util(utilAddress).hashArray(bytes32Array);
        require(hashMsg == _parameter[22]);
        signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[31]), _parameter[32], _parameter[33]);
        bytes32Array = new bytes32[](5);
        bytes32Array[0] = _parameter[34]; // stageHeight
        bytes32Array[1] = _parameter[35]; // gsn
        bytes32Array[2] = _parameter[22]; // lightTxHash
        bytes32Array[3] = _parameter[36]; // fromBalance
        bytes32Array[4] = _parameter[37]; // toBalance
        hashMsg = Util(utilAddress).hashArray(bytes32Array);
        signer = Util(utilAddress).verify(hashMsg, uint8(_parameter[41]), _parameter[42], _parameter[43]);
        require (signer == owner);
        _;
    }

    function defendWrongBalance (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        require (_parameter.length == 44);
        if (address(_parameter[23]) == address(_parameter[1])) {
            require( (uint256(_parameter[36]) + uint256(_parameter[26])) == uint256(_parameter[14]));
            stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[22]].challengedState = false;
            emit Defend(_parameter[22], true);
        } else if (address(_parameter[23]) == address(_parameter[2])) {
            require((uint256(_parameter[36]) + uint256(_parameter[26])) == uint256(_parameter[15]));
            stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[22]].challengedState = false;
            emit Defend(_parameter[22], true);
        } else if (address(_parameter[24]) == address(_parameter[1])) {
            require((uint256(_parameter[36]) - uint256(_parameter[26])) == uint256(_parameter[14]));
            stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[22]].challengedState = false;
            emit Defend(_parameter[22], true);
        } else if (address(_parameter[24]) == address(_parameter[2])) {
            require((uint256(_parameter[36]) - uint256(_parameter[26])) == uint256(_parameter[15]));
            stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[22]].challengedState = false;
            emit Defend(_parameter[22], true);
        }
    }

    function defendSkippedGSN (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        require (_parameter.length == 44);
        require (uint256(_parameter[35]) - uint256(_parameter[13]) == 1);
        stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[22]].challengedState = false;
        emit Defend(_parameter[22], true);
    }

    function defendExistedProof (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        // require (_parameter.length == 22);
        // stages[uint256(_parameter[12])].challengedRepeatedGSNList[_parameter[0]].challengedState = false;
        emit Defend(_parameter[0], true);
    }
}
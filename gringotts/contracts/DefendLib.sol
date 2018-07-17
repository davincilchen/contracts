pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./DefendLib.sol";
import "./Util.sol";
import "./EIP20/SafeMath.sol";

contract DefendLib {
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

    function defendWrongBalances (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        if (address(_parameter[24]) == address(_parameter[1])) {
            require((uint256(_parameter[37]).add(uint256(_parameter[27]))) == uint256(_parameter[14]));
            stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]].challengedState = false;
            emit Defend(_parameter[23], true);
        } else if (address(_parameter[24]) == address(_parameter[2])) {
            require((uint256(_parameter[37]).add(uint256(_parameter[27]))) == uint256(_parameter[15]));
            stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]].challengedState = false;
            emit Defend(_parameter[23], true);
        } else if (address(_parameter[25]) == address(_parameter[1])) {
            require((uint256(_parameter[37]).sub(uint256(_parameter[27]))) == uint256(_parameter[14]));
            stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]].challengedState = false;
            emit Defend(_parameter[23], true);
        } else if (address(_parameter[25]) == address(_parameter[2])) {
            require((uint256(_parameter[37]).sub(uint256(_parameter[27]))) == uint256(_parameter[15]));
            stages[uint256(_parameter[12])].challengedWrongBalanceList[_parameter[23]].challengedState = false;
            emit Defend(_parameter[23], true);
        }
    }

    function defendSkippedGSN (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        require (uint256(_parameter[36]).sub(uint256(_parameter[13])) == 1);
        stages[uint256(_parameter[12])].challengedSkippedGSNList[_parameter[23]].challengedState = false;
        emit Defend(_parameter[23], true);
    }

    // function defendExistProof (bytes32[] _parameter) public onlyOwner {
    //     /*

    //     ===receiptData===
    //     _parameter[0] = _stageHeight
    //     _parameter[1] = _gsn
    //     _parameter[2] = _lightTxHash
    //     _parameter[3] = _fromBalance
    //     _parameter[4] = _toBalance
    //     _parameter[5] = _serverMetadataHash

    //     ===sliceData===
    //     _parameter[6] = _receiptHash
    //     _parameter[7] = _leafElementLength
    //     array _leafElement
    //     _idx
    //     sliceLength
    //     slice
    //     .
    //     .
    //     .
    //     */
    //     require (stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[2]].lightTxHashes[0] == _parameter[2]);
    //     bytes32Array = new bytes32[](6);
    //     bytes32Array[0] = _parameter[0]; // stageHeight
    //     bytes32Array[1] = _parameter[1]; // gsn
    //     bytes32Array[2] = _parameter[2]; // lightTxHash
    //     bytes32Array[3] = _parameter[3]; // fromBalance
    //     bytes32Array[4] = _parameter[4]; // toBalance
    //     bytes32Array[5] = _parameter[5]; // serverMetadaHash
    //     hashMsg = Util(utilAddress).hashArray(bytes32Array);
    //     require (hashMsg == _parameter[6]);
    //     bytes32[] memory leafElements = new bytes32[](uint256(_parameter[7]));
    //     uint256 memory i;
    //     for (i = 8; i < 8 + uint256(_parameter[7]); i++) { // put leafElement to array
    //         leafElements[i - 8] = _parameter[i + uint256(_parameter[7])];
    //     }
    //     i++;
    //     uint256 memory idx = uint256(_parameter[i]);
    //     i++;
    //     uint256 memory sliceLength = uint256(_parameter[i]);
    //     i++;
    //     uint256 memory init = i;
    //     bytes32[] memory slice = new bytes32[](sliceLength);
    //     for (; i < init + sliceLength; i++) { // put leafHash to slice array
    //         slice[i] = _parameter[i + sliceLength];
    //     }
    //     bytes32 hashResult;
    //     require (Util(utilAddress).inBytes32Array(_parameter[1], leafElements));
    //     // content is in leaf array
    //     hashResult = Util(utilAddress).hashArray(leafElements);
    //     require (hashResult == slice[0]);
    //     // hash (content concat) = first node (or second one) hash in slice
    //     hashResult = Util(utilAddress).calculateSliceRootHash(idx, slice);
    //     require (hashResult == stages[uint256(_parameter[0])].receiptRootHash);// compare the root from contract and hashResult
    //     stages[uint256(_parameter[0])].challengedExistedProofList[_parameter[2]].challengedState = false;// receiptHash different from 1 to 4 type
    //     emit Defend(_parameter[2], true);
    // }
}
pragma solidity ^0.4.23;

import "./CryptoFlowLib.sol";
import "./ChallengedLib.sol";
import "./Util.sol";

contract ChallengedLib {
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
    string constant version = "v1.3.0";
    
    struct Stage {
        bytes32 receiptRootHash;
        bytes32 accountRootHash;
		bytes32 data;
	    mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedType1List;// double gsn
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedType2List;// wrong balance more than bond
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedType3List;// wrong balance
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedType4List;// skipped gsn
        mapping (bytes32 => ChallengedLib.ChallengedInfo) challengedType5List;// wrong data
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
        uint256 indexed _challengedType, // { type: 1 - 5 }
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
        if (address(0) == address(_parameter[1]) && address(0) != address(_parameter[2])) {
            // Deposit
            require(signer == address(_parameter[2]));
        } else if (address(0) != address(_parameter[1]) && address(0) == address(_parameter[2])) {
            // Withdraw
            require(signer == address(_parameter[1]));
        } else {
            revert();
        }
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
        if (address(0) == address(_parameter[23]) && address(0) != address(_parameter[24])) {
            // Deposit
            require(signer == address(_parameter[24]));
        } else if (address(0) != address(_parameter[23]) && address(0) == address(_parameter[24])) {
            // Withdraw
            require(signer == address(_parameter[23]));
        } else {
            revert();
        }
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
    
    function challengeDoubleGSN (bytes32[] _parameter) public {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash1,
        parameter[2] = _v1,
        parameter[3] = _r1,
        parameter[4] = _s1,
        parameter[5] = _lightTxHash2,
        parameter[6] = _v2,
        parameter[7] = _r2,
        parameter[8] = _s2
        */
        require (_parameter.length == 9);
        address signer1 = Util(utilAddress).verify(_parameter[1], uint8(_parameter[2]), _parameter[3], _parameter[4]);
        require (signer1 == msg.sender);
        address signer2 = Util(utilAddress).verify(_parameter[5], uint8(_parameter[6]), _parameter[7], _parameter[8]);
        require (signer2 == msg.sender);
        stages[uint256(_parameter[0])].challengedType1List[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[1], _parameter[5]], true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (1, bytes32(msg.sender), _parameter[1]);
    }

    function challengeWrongBalanceLargerThanBond (bytes32[] _parameter) public {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash1,
        parameter[2] = _v1,
        parameter[3] = _r1,
        parameter[4] = _s1,
        parameter[5] = _lightTxHash2,
        parameter[6] = _v2,
        parameter[7] = _r2,
        parameter[8] = _s2
        */
        require (_parameter.length == 9);
        address signer1 = Util(utilAddress).verify(_parameter[1], uint8(_parameter[2]), _parameter[3], _parameter[4]);
        require (signer1 == msg.sender);
        address signer2 = Util(utilAddress).verify(_parameter[5], uint8(_parameter[6]), _parameter[7], _parameter[8]);
        require (signer2 == msg.sender);
        stages[uint256(_parameter[0])].challengedType2List[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[1], _parameter[5]], true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (2, bytes32(msg.sender), _parameter[1]);
    }

    function challengeWrongBalanceLessThanBond (bytes32[] _parameter) public {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash1,
        parameter[2] = _v1,
        parameter[3] = _r1,
        parameter[4] = _s1,
        parameter[5] = _lightTxHash2,
        parameter[6] = _v2,
        parameter[7] = _r2,
        parameter[8] = _s2
        */
        require (_parameter.length == 9);
        address signer1 = Util(utilAddress).verify(_parameter[1], uint8(_parameter[2]), _parameter[3], _parameter[4]);
        require (signer1 == msg.sender);
        address signer2 = Util(utilAddress).verify(_parameter[5], uint8(_parameter[6]), _parameter[7], _parameter[8]);
        require (signer2 == msg.sender);
        stages[uint256(_parameter[0])].challengedType3List[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[1], _parameter[5]], true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (3, bytes32(msg.sender), _parameter[1]);
    }

    function challengeSkippedGSN (bytes32[] _parameter) public {
        /*
        parameter[0] = _stageHeight,
        parameter[1] = _lightTxHash1,
        parameter[2] = _v1,
        parameter[3] = _r1,
        parameter[4] = _s1,
        parameter[5] = _lightTxHash2,
        parameter[6] = _v2,
        parameter[7] = _r2,
        parameter[8] = _s2
        */
        require (_parameter.length == 9);
        address signer1 = Util(utilAddress).verify(_parameter[1], uint8(_parameter[2]), _parameter[3], _parameter[4]);
        require (signer1 == msg.sender);
        address signer2 = Util(utilAddress).verify(_parameter[5], uint8(_parameter[6]), _parameter[7], _parameter[8]);
        require (signer2 == msg.sender);
        stages[uint256(_parameter[0])].challengedType4List[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[1], _parameter[5]], true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (4, bytes32(msg.sender), _parameter[1]);
    }

    function challengeIntegrity (bytes32[] _parameter) public {
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
        stages[uint256(_parameter[0])].challengedType5List[_parameter[1]] = ChallengedLib.ChallengedInfo(msg.sender, [_parameter[1], 0x0], true, false);
        stages[uint256(_parameter[0])].challengedLightTxHashes.push(_parameter[1]);
        emit Challenge (5, bytes32(msg.sender), _parameter[1]);
    }

    function defendType1 (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        require (uint256(_parameter[13]) != uint256(_parameter[35]));// compare gsn
        stages[uint256(_parameter[0])].challengedType1List[_parameter[0]].challengedState = false;
    }

    function defendType2 (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        // check balance
        stages[uint256(_parameter[0])].challengedType1List[_parameter[0]].challengedState = false;
    }
}

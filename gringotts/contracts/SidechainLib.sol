pragma solidity ^0.4.23;

contract SidechainLib {
    mapping (uint256 => SidechainLib.Stage) public stages;
    mapping (bytes32 => SidechainLib.Log) public depositLogs;
    mapping (bytes32 => SidechainLib.Log) public withdrawLogs;
    uint256 public stageHeight;
    address public owner;

    string constant version = "v1.2.1";

	struct Stage {
		bytes32 receiptRootHash;
		bytes32 accountRootHash;
		bytes32 data;
	}

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
        uint256 indexed _type, // { 0: deposit, 1: proposeWithdrawal, 2: instantWithdrawal}
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
        _parameter[3] = _value
        _parameter[4] = _fee
        _parameter[5] = _lsn

        ===clientLtxSignature===
        _parameter[6] = _vFromClient
        _parameter[7] = _rFromClient
        _parameter[8] = _sFromClient

        ===receipt===
        _parameter[9] = _gsn,
        _parameter[10] = _fromBalance,
        _parameter[11] = _toBalance,

        ===serverLtxSignature===
        _parameter[12] = _vFromServer
        _parameter[13] = _rFromServer
        _parameter[14] = _sFromServer

        ===serverReceiptSignature===
        _parameter[15] = _vFromServer,
        _parameter[16] = _rFromServer,
        _parameter[17] = _sFromServer,

        _parameter[18] = _dsn (deposit)
        */
        bytes32[] memory bytes32Array = new bytes32[](5);
        bytes32Array[0] = _parameter[1]; // from
        bytes32Array[1] = _parameter[2]; // to
        bytes32Array[2] = _parameter[3]; // value
        bytes32Array[3] = _parameter[4]; // fee
        bytes32Array[4] = _parameter[5]; // lsn
        bytes32 hashMsg = hashArray(bytes32Array);
        require(hashMsg == _parameter[0]);
        address signer = verify(hashMsg, uint8(_parameter[6]), _parameter[7], _parameter[8]);
        if (address(0) == address(_parameter[1]) && address(0) != address(_parameter[2])) {
            // Deposit
            require(signer == address(_parameter[2]));
            require(signer == address(depositLogs[_parameter[18]].client));
            require(_parameter[3] == depositLogs[_parameter[18]].value);
        } else if (address(0) != address(_parameter[1]) && address(0) == address(_parameter[2])) {
            // Withdraw
            require(signer == address(_parameter[1]));
        } else {
            revert();
        }

        bytes32Array[0] = bytes32(stageHeight+1); // stageHeight
        bytes32Array[1] = _parameter[9];          // gsn
        bytes32Array[2] = _parameter[0];          // lightTxHash
        bytes32Array[3] = _parameter[10];         // fromBalance
        bytes32Array[4] = _parameter[11];         // toBalance
        hashMsg = hashArray(bytes32Array);
        signer = verify(hashMsg, uint8(_parameter[15]), _parameter[16], _parameter[17]);
        require (signer == owner);
        _;
    }

    function inBytes32Array (bytes32 data, bytes32[] dataArray) constant returns (bool){
        for (uint i = 0; i < dataArray.length; i++) {
            if (data == dataArray[i]) {
                return true;
            }
        }
        return false;
    }

    function hashArray (bytes32[] dataArray) constant returns (bytes32) {
        require(dataArray.length > 0);
        string memory str = bytes32ToString(dataArray[0]);
        for (uint i = 1; i < dataArray.length; i++) {
            str = strConcat(str, bytes32ToString(dataArray[i]));
        }
        return sha3(str);
    }

    function calculateSliceRootHash (uint idx, bytes32[] slice) constant returns (bytes32) {
        require(slice.length > 0);
        bytes32 rootHash = slice[0];
        string memory str;
        for (uint i = 1; i < slice.length; i++) {
            str = bytes32ToString(rootHash);
            if (idx % 2 == 0) {
                str = strConcat(str, bytes32ToString(slice[i]));
            } else {
                str = strConcat(bytes32ToString(slice[i]), str);
            }
            rootHash = sha3(str);
            idx = idx >> 1;
        }
        return rootHash;
    }

    function strConcat (string _a, string _b) constant returns (string) {
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory length_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_c = bytes(length_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) {bytes_c[k++] = bytes_a[i];}
        for (i = 0; i < bytes_b.length; i++) {bytes_c[k++] = bytes_b[i];}
        return string(bytes_c);
    }

    function bytes32ToString (bytes32 b32) constant returns (string) {
        bytes memory bytesString = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byte char = byte(bytes32(uint(b32) * 2 ** (8 * i)));
            bytesString[i*2+0] = uintToAscii(uint(char) / 16);
            bytesString[i*2+1] = uintToAscii(uint(char) % 16);
        }
        return string(bytesString);
    }

    function uintToAscii (uint number) constant returns(byte) {
        if (number < 10) {
            return byte(48 + number);
        } else if (number < 16) {
            // asciicode a = 97 return 10
            return byte(87 + number);
        } else {
            revert();
        }
    }

    function verify (bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) constant returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = sha3(prefix, _message);
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
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

    function proposeDeposit (bytes32[] _parameter) payable {
        /*
        _parameter[0] = dsn
        _parameter[1] = msg.sender
        _parameter[2] = msg.value
        */
        depositLogs[_parameter[0]].stage = bytes32(stageHeight + 1);
        depositLogs[_parameter[0]].client = _parameter[1];
        depositLogs[_parameter[0]].value = _parameter[2];

        emit ProposeDeposit (_parameter[0], _parameter[1], _parameter[2]);
    }

    function deposit (bytes32[] _parameter) isSigValid (_parameter) public onlyOwner {
        depositLogs[_parameter[18]].flag = true;

        emit VerifyReceipt ( 0,
                             _parameter[9],
                             _parameter[0],
                             _parameter[10],
                             _parameter[11],
                             [ _parameter[12],
                               _parameter[13],
                               _parameter[14]],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]]);
    }

    function proposeWithdrawal (bytes32[] _parameter) isSigValid (_parameter) public {
        /*
        wsn = concat(stageHeight + gsn)
        */
        bytes32[] memory bytes32Array = new bytes32[](2);
        bytes32Array[0] = bytes32(stageHeight+1);
        bytes32Array[1] = _parameter[9];
        bytes32 wsn = hashArray(bytes32Array);

        withdrawLogs[wsn].stage = bytes32(stageHeight+1);
        withdrawLogs[wsn].client = _parameter[2];
        withdrawLogs[wsn].value = bytes32(uint256(_parameter[3]) - uint256(_parameter[4])); // value - fee

        emit VerifyReceipt ( 1,
                             _parameter[9],
                             _parameter[0],
                             _parameter[10],
                             _parameter[11],
                             [ _parameter[12],
                               _parameter[13],
                               _parameter[14]],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]]);
    }

    function withdraw (bytes32[] _parameter) public {
        /*
        _parameter[0] = _wsn
        */
        // flag = false
        require(!withdrawLogs[_parameter[0]].flag);
        // over challenge time
        require (uint256(withdrawLogs[_parameter[0]].stage) < stageHeight);
        address client = address(withdrawLogs[_parameter[0]].client);
        uint256 value = uint256(withdrawLogs[_parameter[0]].value);
        client.transfer(value);
        withdrawLogs[_parameter[0]].flag = true;

        emit Withdraw (_parameter[0], bytes32(client), bytes32(value));
    }

    function instantWithdraw (bytes32[] _parameter) isSigValid (_parameter) public {
        // instantWithdraw condition
        require (uint256(_parameter[3]) <= 100);
        /*
        wsn = concat((stageHeight+1) + gsn)
        */
        bytes32[] memory bytes32Array = new bytes32[](2);
        bytes32Array[0] = bytes32(stageHeight+1);
        bytes32Array[1] = _parameter[9];
        bytes32 wsn = hashArray(bytes32Array);

        withdrawLogs[wsn].stage = bytes32(stageHeight+1);
        withdrawLogs[wsn].client = _parameter[2];
        withdrawLogs[wsn].value = _parameter[3];
        withdrawLogs[wsn].flag = true;

        address(_parameter[2]).transfer(uint256(_parameter[3]));

        emit VerifyReceipt ( 2,
                             _parameter[9],
                             _parameter[0],
                             _parameter[10],
                             _parameter[11],
                             [ _parameter[12],
                               _parameter[13],
                               _parameter[14]],
                             [ _parameter[15],
                               _parameter[16],
                               _parameter[17]]);
    }
}

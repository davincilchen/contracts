pragma solidity ^0.4.15;

contract SidechainLib {
    mapping (uint256 => SidechainLib.Stage) private stages;
    mapping (bytes32 => SidechainLib.Log) public logs;
    uint256 public stageHeight;
    address public owner;

    string constant version = "v0.1";

	struct Stage {
        bytes32 stageHash;
		bytes32 balanceRootHash;
		bytes32 receiptRootHash;
		bytes32 data;
	}

	struct Log {
		bytes32 stageHeight;
		bytes32 lsn;
		bytes32 client;
		bytes32 value;
		bool flagDeposit;
	}

    event ProposeDeposit (
        bytes32 _lightTxHash,
        bytes32 _client,
        bytes32 _value,
        bytes32 _fee,
        bytes32 _lsn,
        bytes32 _stageHeight,
        bytes32 _v,
        bytes32 _r,
        bytes32 _s
    );

    event Deposit (
        bytes32 _gsn,
        bytes32 _lightTxHash,
        bytes32 _fromBalance,
        bytes32 _toBalance
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function inBytes32Array(bytes32 data, bytes32[] dataArray) constant returns (bool){
        for (uint i = 0; i < dataArray.length; i++) {
            if (data == dataArray[i]) {
                return true;
            }
        }
        return false;
    }

    function hashArray(bytes32[] dataArray) constant returns (bytes32) {
        require(dataArray.length > 0);
        string memory str = bytes32ToString(dataArray[0]);
        for (uint i = 1; i < dataArray.length; i++) {
            str = strConcat(str, bytes32ToString(dataArray[i]));
        }
        return sha3(str);
    }

    function calculateSliceRootHash(uint idx, bytes32[] slice) constant returns (bytes32) {
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

    function strConcat(string _a, string _b) constant returns (string) {
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

    function addressToString (address addr) constant returns (string) {
        bytes memory bytesString = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte char = byte(bytes20(uint(addr) * 2 ** (8 * i)));
            bytesString[i*2+0] = uintToAscii(uint(char) / 16);
            bytesString[i*2+1] = uintToAscii(uint(char) % 16);
        }
        return string(bytesString);
    }

    function uintToAscii(uint number) constant returns(byte) {
        if (number < 10) {
            return byte(48 + number);
        } else if (number < 16) {
            // asciicode a = 97 return 10
            return byte(87 + number);
        } else {
            revert();
        }
    }

    function verify(bytes32 _message, uint8 _v, bytes32 _r, bytes32 _s) constant returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = sha3(prefix, _message);
        address signer = ecrecover(prefixedHash, _v, _r, _s);
        return signer;
    }

    function attachStage(bytes32[] _parameter) { 
        /*
        _parameter[0] = _balanceRootHash
        _parameter[1] = _receiptRootHash
        _parameter[2] = _data
        */
        stageHeight++;
        stages[stageHeight].balanceRootHash = _parameter[0];
        stages[stageHeight].receiptRootHash = _parameter[1];
        stages[stageHeight].data = _parameter[2];
    }

    function proposeDeposit(bytes32[] _parameter) payable {
        /*
        _parameter[0] = _lightTxHash
        _parameter[1] = _fee
        _parameter[2] = _lsn
        _parameter[3] = _v
        _parameter[4] = _r
        _parameter[5] = _s      
        */
        logs[_parameter[0]].stageHeight = bytes32(stageHeight+1);
        logs[_parameter[0]].lsn = bytes32(_parameter[2]);
        logs[_parameter[0]].client = bytes32(msg.sender);
        logs[_parameter[0]].value = bytes32(msg.value);
        logs[_parameter[0]].flagDeposit = false;

        ProposeDeposit ( _parameter[0], 
                         logs[_parameter[0]].client, 
                         logs[_parameter[0]].value, 
                         _parameter[1], 
                         _parameter[2], 
                         logs[_parameter[0]].stageHeight, 
                         _parameter[3], 
                         _parameter[4], 
                         _parameter[5] );
    }

    function deposit (bytes32[] _parameter) onlyOwner {
        /*
        _parameter[0] = _gsn,
        _parameter[1] = _lightTxHash,
        _parameter[2] = _fromBalance,
        _parameter[3] = _toBalance,
        _parameter[4] = _v,
        _parameter[5] = _r,
        _parameter[6] = _s
        */
        bytes32[] memory bytes32Array = new bytes32[](4);
        bytes32Array[0] = _parameter[0];
        bytes32Array[1] = _parameter[1];
        bytes32Array[2] = _parameter[2];
        bytes32Array[3] = _parameter[3];

        bytes32 hashMsg = hashArray(bytes32Array);
        address signer = verify(hashMsg, uint8(_parameter[4]), _parameter[5], _parameter[6]);
        require (signer == owner);
        logs[_parameter[1]].flagDeposit = true;

        Deposit (_parameter[0], _parameter[1], _parameter[2], _parameter[3]);
    }

}
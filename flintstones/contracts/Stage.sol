pragma solidity ^0.4.15;

import "./BoosterLibrary.sol";

contract Stage {
    address public owner; //IFC contract
    bytes32 public stageHash;
    bytes32 public rootHash;
    address public lib; // IFC Lib
    bool public completed;
    string public version = "1.0.1";
    uint public objectionTime;
    uint public finalizedTime;
    string public data;

    mapping (bytes32 => ObjectionInfo) public objections;
    bytes32[] public objectionableLightTxHashes;

    struct ObjectionInfo {
        address customer;
        bool objectionSuccess;
        bool getCompensation;
    }
   
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Stage(
        bytes32 _stageHash,
        bytes32 _rootHash,
        address _lib,
        uint _objectionTimePeriod,
        uint _finalizedTimePeriod,
        string _data)
    {
        owner = msg.sender;
        stageHash = _stageHash;
        rootHash = _rootHash;
        lib = _lib;
        if (_stageHash == 0x0 && _rootHash == 0x0) { 
            completed = true;
        } else {
            completed = false;
        }
        objectionTime = now + _objectionTimePeriod;
        finalizedTime = objectionTime + _finalizedTimePeriod;
        data = _data;
    }

    function addObjectionableLightTxHash(bytes32 _lightTxHash, address _customer) onlyOwner {
        require (now < objectionTime);
        require(BoosterLibrary(lib).inBytes32Array(_lightTxHash, objectionableLightTxHashes) == false);
        objections[_lightTxHash] = ObjectionInfo(_customer, true, false);
        objectionableLightTxHashes.push(_lightTxHash);
    }

    function resolveObjections(bytes32 _lightTxHash) onlyOwner {
        objections[_lightTxHash].objectionSuccess = false;
    }

    function resolveCompensation(bytes32 _lightTxHash) onlyOwner {
        objections[_lightTxHash].getCompensation = true;
    }

    function setCompleted() onlyOwner {
        require(now > finalizedTime);
        completed = true;
    }

    function getObjectionableLightTxHashes() constant returns (bytes32[]) {
        return objectionableLightTxHashes;
    }

    function isSettle() constant returns (bool) {
        for (uint i = 0; i < objectionableLightTxHashes.length; i++) {
            if (objections[objectionableLightTxHashes[i]].objectionSuccess && !objections[objectionableLightTxHashes[i]].getCompensation) {
                return false;
            }
        }
        return true;
    }
}

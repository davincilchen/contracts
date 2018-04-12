pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "../contracts/SidechainLib.sol";

contract TestSidechainLib {
	function testDeposit() {
		uint256 _gsn = 15;
		// 0x000000000000000000000000000000000000000000000000000000000000000f
		bytes32 _lightTxHash = 0xb2f3af031ae48792022200cee796881911c005487b02bdae742a39c89623e6c6;
		uint256 _fromBalance = 50;
		// 0x0000000000000000000000000000000000000000000000000000000000000032
		uint256 _toBalance = 500;
		// 0x00000000000000000000000000000000000000000000000000000000000001f4
		bytes32 hashMsg = SidechainLib.hashArray([bytes32(_gsn), _lightTxHash, bytes32(_fromBalance), bytes32(_toBalance)]);			
		bytes32 expected = 0xcb994442ed1cc127fcbf05d90e2881f542f5200defe94cd2e58fd81029966a24;
		Assert.equal(hashMsg, expected, "hashMsg should equal to expected");
	}

}
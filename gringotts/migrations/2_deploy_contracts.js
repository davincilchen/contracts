var SidechainLib = artifacts.require("./SidechainLib.sol");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");
var TWX = artifacts.require("./EIP20/TWX.sol");

module.exports = function(deployer) {
  deployer.deploy(TWX);
  deployer.deploy(SidechainLib).then(function() {
  	return deployer.deploy(InfinitechainManager, SidechainLib.address);
  });
};

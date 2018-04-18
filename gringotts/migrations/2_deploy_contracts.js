var SidechainLib = artifacts.require("./SidechainLib.sol");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");
var Sidechain = artifacts.require("./Sidechain.sol");

module.exports = function(deployer) {

  deployer.deploy(SidechainLib).then(function() {
  	return deployer.deploy(InfinitechainManager, SidechainLib.address);
  });
};

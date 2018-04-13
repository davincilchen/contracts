var SidechainLib = artifacts.require("./SidechainLib");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");

module.exports = function(deployer) {
  deployer.deploy(SidechainLib).then(function() {
  	return deployer.deploy(InfinitechainManager, SidechainLib.address);
  });
};

var SidechainLib = artifacts.require("./SidechainLib");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");

module.exports = function(deployer) {
  deployer.deploy(SidechainLib);
  deployer.link(SidechainLib, InfinitechainManager);
  deployer.deploy(InfinitechainManager);
};

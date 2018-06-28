var Util = artifacts.require("./Util.sol");
var CryptoFlowLib = artifacts.require("./CryptoFlowLib.sol");
var ChallengedLib = artifacts.require("./ChallengedLib.sol");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");
var TWX = artifacts.require("./EIP20/TWX.sol");

module.exports = function(deployer) {
  deployer.deploy(TWX);
  deployer.deploy(Util).then(async function() {
    await deployer.deploy(CryptoFlowLib, Util.address);
    await deployer.deploy(ChallengedLib, Util.address);
    await deployer.deploy(InfinitechainManager, CryptoFlowLib.address, ChallengedLib.address);
  });
};

var Util = artifacts.require("./Util.sol");
var CryptoFlowLib = artifacts.require("./CryptoFlowLib.sol");
var ChallengedLib = artifacts.require("./ChallengedLib.sol");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");
var TWX = artifacts.require("./EIP20/TWX.sol");

module.exports = async function(deployer) {
    deployer.deploy(TWX);
    await deployer.deploy(Util);
    await deployer.deploy(CryptoFlowLib);
    await deployer.deploy(ChallengedLib);
    await deployer.deploy(InfinitechainManager, Util.address, CryptoFlowLib.address, ChallengedLib.address);
};

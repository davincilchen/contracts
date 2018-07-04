var Util = artifacts.require("./Util.sol");
var CryptoFlowLib = artifacts.require("./CryptoFlowLib.sol");
var ChallengedLib = artifacts.require("./ChallengedLib.sol");
var DefendLib = artifacts.require("./DefendLib.sol");
var InfinitechainManager = artifacts.require("./InfinitechainManager.sol");
var TWX = artifacts.require("./EIP20/TWX.sol");

module.exports = function(deployer) {
    deployer.deploy(TWX);
    deployer.deploy(Util).then(async function() {
        await deployer.deploy(CryptoFlowLib);
        await deployer.deploy(ChallengedLib);
        await deployer.deploy(DefendLib);
        await deployer.deploy(InfinitechainManager, Util.address, CryptoFlowLib.address, ChallengedLib.address, DefendLib.address);
    });
};

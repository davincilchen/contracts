/*
node testDeployBooster.js
--managerAddress 0x111 // infinitechainManager contract address.
--boosterOwner 0x222 // booster owner address, default infinitechainManager owner address.
--assetAddress 0x333 // support token contract address, default empty array.
--assetAddress 0x444 // if support token more than one.
--maxWithdraw 10 // maximum value of instant withdraw, default 10 ether.
--network devnet // network setting, default devnet. opt: 1. devnet 2. testnet 3. mainnet
*/
var argv = require('minimist')(process.argv.slice(2), { string: ['managerAddress', 'boosterOwner', 'assetAddress', 'maxWithdraw', 'network'] });
let InfinitechainManager = require('./build/contracts/InfinitechainManager.json');
let EthUtils = require('ethereumjs-util');
let Web3 = require('web3');
let env = require('./env');

let network = env.devnet;
if (argv.network == 'testnet') {
    network = env.testnet;
} else if (argv.network == 'mainnet') {
    network = env.mainnet;
}
let web3 = new Web3(new Web3.providers.HttpProvider(network.web3Url));
let publickey = '0x' + EthUtils.privateToPublic('0x' + network.privateKey).toString('hex');
let account = '0x' + EthUtils.pubToAddress(publickey).toString('hex');

let im = web3.eth.contract(InfinitechainManager.abi).at(argv.managerAddress);
let boosterNumber = im.boosterNumber().toNumber();
let boosterOwner = argv.boosterOwner? argv.boosterOwner : im.owner();
let assetList = [];
if (typeof argv.assetAddress == 'string') {
    assetList.push(argv.assetAddress);
} else if (typeof argv.assetAddress == 'object') {
    assetList = argv.assetAddress;
}
let maxWithdraw = argv.maxWithdraw? web3.toWei(parseInt(argv.maxWithdraw)) : web3.toWei(10);

im.deployBooster(boosterOwner, assetList, maxWithdraw, { from: account, gas: 1500000 });
let second = 0;
let timeout = 120;
let getBoosterAddress = setInterval(() => {
    second = second + 1;
    if (second >= timeout || im.boosterAddress(boosterNumber) != '0x0000000000000000000000000000000000000000') {
        console.log(im.boosterAddress(boosterNumber));
        clearInterval(getBoosterAddress);
    }
} ,1000);

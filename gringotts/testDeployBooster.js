/*
node testDeployBooster.js
--boosterOwner 0x111 // booster owner address
--assetAddress 0x222 // asset contract address
--assetAddress 0x333 // if assetAddress more than one
--maxWithdraw 10 // maximum value of instant withdraw, default 10
--managerAddress 0x444 // infinitechainManager contract address
*/
var argv = require('minimist')(process.argv.slice(2), { string: ['managerAddress', 'boosterOwner', 'assetAddress', 'maxWithdraw'] });
let Web3 = require('web3');
let env = require('./env');
let InfinitechainManager = require('./build/contracts/InfinitechainManager.json');
let web3Url = 'http://' + env.web3Host + ':' + env.web3Port;
let web3 = new Web3(new Web3.providers.HttpProvider(web3Url));
let im = web3.eth.contract(InfinitechainManager.abi).at(argv.managerAddress);
let boosterNumber = im.boosterNumber().toNumber();
let assetList = [];
if (typeof argv.assetAddress == 'string') {
    assetList.push(argv.assetAddress);
} else if (typeof argv.assetAddress == 'object') {
    assetList = argv.assetAddress;
}
let maxWithdraw = web3.toWei(10);
if (argv.maxWithdraw) {
    maxWithdraw = web3.toWei(parseInt(argv.maxWithdraw));
}
im.deployBooster(argv.boosterOwner, assetList, maxWithdraw, { from: env.account, gas: 1500000 });
let second = 0;
let timeout = 120;
let getBoosterAddress = setInterval(() => {
    second = second + 1;
    if (second >= timeout || im.boosterAddress(boosterNumber) != '0x0000000000000000000000000000000000000000') {
        console.log(im.boosterAddress(boosterNumber));
        clearInterval(getBoosterAddress);
    }
} ,1000);

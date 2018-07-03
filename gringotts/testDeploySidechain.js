var argv = require('minimist')(process.argv.slice(2), { string: ['managerAddress', 'sidechainOwner'] });
let Web3 = require('web3');
let env = require('./env');
let InfinitechainManager = require('./build/contracts/InfinitechainManager.json');
let web3Url = 'http://' + env.web3Host + ':' + env.web3Port;
let web3 = new Web3(new Web3.providers.HttpProvider(web3Url));
let im = web3.eth.contract(InfinitechainManager.abi).at(argv.managerAddress);
let sidechainNumber = im.sidechainNumber().toNumber();
im.deploySidechain(argv.sidechainOwner, ['0x0'], web3.toWei(10), { from: env.account, gas: 1000000 });
let second = 0;
let timeout = 120;
let countSecond = () => {
    second = second + 1;
    t = setTimeout(countSecond, 1000);
    if (second >= timeout || im.sidechainAddress(sidechainNumber) != '0x0000000000000000000000000000000000000000') {
        console.log(im.sidechainAddress(sidechainNumber));
        clearTimeout(t);
    }
}
countSecond();

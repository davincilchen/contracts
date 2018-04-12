let Web3 = require('web3');
let EthUtils = require('ethereumjs-util');
let env = require('./env');

let web3Url = 'http://' + env.web3Host + ':' + env.web3Port;
let web3 = new Web3(new Web3.providers.HttpProvider(web3Url));
const privatekey = env.privateKey;
const publickey = '0x' + EthUtils.privateToPublic('0x' + privatekey).toString('hex');
const account = '0x' + EthUtils.pubToAddress(publickey).toString('hex');

web3.personal.unlockAccount(account, env.password);

module.exports = {
    networks: {
        development: {
            host: env.web3Host,
            port: env.web3Port,
            network_id: '*',
            from: account
        },
        staging: {
            host: '54.254.162.50',
            port: '8545',
            network_id: '*',
            from: '0x50afb1b4c52c64daed49ab8c3aa82b0609b75db0'
        }
    }
}
fs = require('fs');

let dev = {};
if (fs.existsSync('./env.js')) {
    let Web3 = require('web3');
    let EthUtils = require('ethereumjs-util');
    let env = require('./env');

    let web3Url = 'http://' + env.web3Host + ':' + env.web3Port;
    let web3 = new Web3(new Web3.providers.HttpProvider(web3Url));
    const account = env.account;
    web3.personal.unlockAccount(account, env.password);
    
    dev = {
        host: env.web3Host,
        port: env.web3Port,
        network_id: '*',
        from: account,
        gas: 4700000
    }

} else {
    dev = {
        host: 'localhost',
        port: 8545,
        network_id: '*',
        gas: 4700000
    }
}

module.exports = {
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    networks: {
        development: dev,
        staging: {
            host: '<HOST_DOMAIN>',
            port: '<HOST_PORT>',
            network_id: '*',
            from: '<KEY>'
        }
    }
}

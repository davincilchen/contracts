let EthUtils = require('ethereumjs-util');
let env = require('./env');

let devnet = env.devnet;
let testnet = env.testnet;
let mainnet = env.mainnet;

console.log('----------------Devnet-------------------');
const devPrivatekey = devnet.privateKey;
if (devPrivatekey) {
  const devPublickey = '0x' + EthUtils.privateToPublic('0x' + devPrivatekey).toString('hex');
  const devAccount = '0x' + EthUtils.pubToAddress(devPublickey).toString('hex');
  console.log('Private key: ' + devPrivatekey);
  console.log('Public key: ' + devPublickey);
  console.log('address: ' + devAccount);
} else {
  console.log('Not detected.');
}


console.log('----------------Testnet-------------------');
const testnetPrivatekey = testnet.privateKey;
if (testnetPrivatekey) {
  const testnetPublickey = '0x' + EthUtils.privateToPublic('0x' + testnetPrivatekey).toString('hex');
  const testnetAccount = '0x' + EthUtils.pubToAddress(testnetPublickey).toString('hex');
  console.log('Private key: ' + testnetPrivatekey);
  console.log('Public key: ' + testnetPublickey);
  console.log('address: ' + testnetAccount);
} else {
  console.log('Not detected.');
}

console.log('----------------Mainnet-------------------');
const mainnetPrivatekey = mainnet.privateKey;
if (mainnetPrivatekey) {
  const mainnetPublickey = '0x' + EthUtils.privateToPublic('0x' + mainnetPrivatekey).toString('hex');
  const mainnetAccount = '0x' + EthUtils.pubToAddress(mainnetPublickey).toString('hex');
  console.log('Private key: ' + mainnetPrivatekey);
  console.log('Public key: ' + mainnetPublickey);
  console.log('address: ' + mainnetAccount);
} else {
  console.log('Not detected.');
}

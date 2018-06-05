# BOLT Contract

Deploy a BOLT contract is the first thing you need to do in BOLT protocol. The contract itself manages every deposit/withdrawal of ERC20 assets and ETH. Furthermore, it checks and validates all the transactions to prevent any invalid withdrawal. A centrailized service collaborates with our [Gringotts](https://github.com/BOLT-Protocol/gringotts) could prevent client's digital assets from hacking, collusion or any other potential attack so that a centralized service could build the trust with its customers with pure cryptographic and mathematics.

## How to deploy

Install dependencies & configure environment variables.

```
npm install
npm install -g truffle
cp env.js.example env.js
```

There are 4 informations you need to provide.

1. `web3Host`: Ethereum full node host.
2. `web3Port`: Ethereum full node port, usually 8545.
3. `account`: Your coinbase address in your Ethereum full node.
4. `password`: Key phrases of your coinbase address.

```javascript
// env.js
let env = {
    web3Host: 'localhost',
    web3Port: '8545',
    account: 'YOUR_COINBASE_ADDRESS',
    password: 'PASSWORD'
};
```

Start to deploy BOLT contracts and fetching a new sidechain address.

```javascript
> truffle deploy --reset
Deploying InfinitechainManager...
  ... 0x921bdb32e31902cc0fb464f516c372f0d0d6cc647d7d12daade48de47f03ef36
  InfinitechainManager: 0x96e8f47086ab932bd3487f1f73d1df65cdda2ce9
Saving successful migration to network...
```

Copy the address of InfinitechainManager and follow these instructions to get a new sidechain address.

These instructions would teach you to deploy a contract which controled by **your address**. Also, it could protect all of the **off-chain** ETH(asset_id: **"0x0"**) depost/remittance/withdrawal behaviors and allow instant withdrawal if the value is under **10** ETH.

```
> truffle console
> i = InfinitechainManager.at('Address of InfinitechainManager')
> i.deploySidechain("your address", "0x0", "10")
> i.sidechainAddress(0)

// This is your new sidechain address
'0x175b74f11d384245cbc0c1474fe2dc43a5c703fd'
```

Remember the sidechain address and we will use it in [Gringotts](https://github.com/BOLT-Protocol/gringotts), an **off-chain** ledger of BOLT protocol.

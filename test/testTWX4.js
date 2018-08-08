//truffle test test/testTWX3.js 
const TWX = artifacts.require('./EIP20/TWX.sol')
    
contract('TWX', function ([owner, donor]) {
  
    var accounts;
    // in web front-end, use an onload listener and similar to this manual flow ... 
    web3.eth.getAccounts(function(err,res) { accounts = res; });
    // t = TWX.at("0x9133614a59539e61228de09bfc6018b122060736")
    // t.getSenderAddress({from: accounts[1]})

    // var acc;
    // acc = eth.accounts
    // web3.personal.unlockAccount(acc[1]);
    // t.mint(1, { from: acc[1] , gas: 4000000, gasPrice: 100000000000 } )
    

    it("Caller address (account 0)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getCallAddress({from: accounts[0]});
        }).then(function(address) {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
            console.log(`Call function successful! getCallAddress ${address}`)
        }).catch(function(e) {
        // There was an error! Handle it.
            //alert("Transaction error!")
            console.log(`Call function error!`)
        });
    });

    it("Caller address (account 1)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getCallAddress({from: accounts[1]});
        }).then(function(address) {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
            console.log(`Call function successful! getCallAddress ${address}`)
        }).catch(function(e) {
        // There was an error! Handle it.
            //alert("Transaction error!")
            console.log(`Call function error!`)
        });
    });
    
    it("get contract address (account 0)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getContractAdd({from: accounts[0]});
        }).then(function(address) {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
            console.log(`Call function successful! getContractAdd ${address}`)
        }).catch(function(e) {
        // There was an error! Handle it.
            //alert("Transaction error!")
            console.log(`Call function error!`)
        });
    });

    it("get contract address (account 1)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getContractAdd({from: accounts[1]});
        }).then(function(address) {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
            console.log(`Call function successful! getContractAdd ${address}`)
        }).catch(function(e) {
        // There was an error! Handle it.
            //alert("Transaction error!")
            console.log(`Call function error!`)
        });
    });
    

    
    /*
      let instance
      let theOwner = accounts[0]
      let account = accounts[1]
    
      beforeEach(async () => {
        instance = await TWx.deployed()
      })
    
      it("should check restriction", async () => {
        try {
          let result = await instance.restrictedFunction.call({from: account})
          assert.equal(result.toString(), theOwner)
        } catch (e) {
          console.log(`${account} is not owner`)
        }
      })
    */
      
})
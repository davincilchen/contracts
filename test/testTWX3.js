//truffle test test/testTWX3.js 
const TWX = artifacts.require('./EIP20/TWX.sol')
    
contract('TWX', function ([owner, donor]) {

    it("call address (account 1)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getCallAddress({from: accounts[1]});
        }).then(function() {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
        }).catch(function(e) {
        // There was an error! Handle it.
            //alert("Transaction error!")
        });
    });
    
    it("call address (account 0)", function() {

        return TWX.deployed().then(function(instance) {
            return instance.getCallAddress({from: accounts[0]});
        }).then(function() {
            // If this callback is called, the transaction was successfully processed.
            //alert("Transaction successful!")
        }).catch(function(e) {
            // There was an error! Handle it.
            //alert("Transaction error!")
        });
    });
    
})
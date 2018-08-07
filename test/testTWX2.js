//truffle test test/testTWX2.js 
const TWX = artifacts.require('./EIP20/TWX.sol')
                                
contract('TWX', function ([owner, donor]) {
    let fundTWX;

    it("should put 10000 TWX in the first account", function() {

        return TWX.deployed().then(function(instance) {

            return instance.getBalance.call(accounts[0]);

        }).then(function(balance) {
            console.log(balance);
            assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");

        });
    });
    

})
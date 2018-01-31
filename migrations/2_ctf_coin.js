var CTFCoin = artifacts.require("CTFCoin");
var MyContract = artifacts.require("MyContract");

module.exports = function(deployer) {
  deployer.deploy(CTFCoin, "CTF Coin", "CTF", 8);
  deployer.deploy(MyContract);
};

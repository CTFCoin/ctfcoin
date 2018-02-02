var Web3 = require("web3");
var badge_artifacts = require("../../build/contracts/Badge.json");

import { default as contract } from 'truffle-contract'

var Badge = contract(badge_artifacts);


window.addEventListener('load', function() {
  // Supports Metamask and Mist, and other wallets that provide 'web3'.
  if (typeof web3 !== 'undefined') {
    // Use the Mist/wallet provider.
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.error("No web3 detected.");
    // No web3 detected. Show an error to the user or use Infura: https://infura.io/
  }
});

window.doSomething = () => {
    console.log("I'm doing something.");
}

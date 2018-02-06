var Web3 = require("web3");
var badge_artifacts = require("../../build/contracts/Badge.json");

import { default as contract } from 'truffle-contract'

var Badge = contract(badge_artifacts);
var badge;
var accounts;
var account;

window.addEventListener('load', function() {
  // Supports Metamask and Mist, and other wallets that provide 'web3'.
  if (typeof web3 !== 'undefined') {
    // Use the Mist/wallet provider.
    window.web3 = new Web3(web3.currentProvider);
    Badge.setProvider(web3.currentProvider);

    web3.eth.getAccounts(function(err, accs) {
      if (err != null) {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0) {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];
    });


    Badge.deployed().then(function(instance) {
      badge = instance;
    });

  } else {
    // No web3 detected. Show an error to the user or use Infura: https://infura.io/
    alert("No web3 detected.");
  }
});

function epochTime() {
  let d = new Date();
  return (d.getTime() - d.getMilliseconds()) / 1000
}

function findEvent(eventName, logs) {
  for (var i = 0; i < logs.length; i++) {
    var log = logs[i];
    if (log.event == eventName) {
      return log;
    }
  }
}

window.doSomething = () => {
  console.log("I'm doing something.");
}

window.registerCtf = () => {
  let name = "A ctf name";
  let url = "https://a.url";
  let startTime = epochTime() + 60;
  let endTime = epochTime() + 90;

  badge.registerCtf(name, url, startTime, endTime, {from: account, gas: 6000000}).then(function(result) {
    console.log("Registered Ctf!");
    console.log(result);

    let ctfRegisteredEvent = findEvent("CtfRegistered", result.logs);
    console.log("ID of your registered CTF: " + ctfRegisteredEvent.args._ctfId.valueOf());

  });
}

window.submitWriteup = () => {
  let ctfId = 10;
  let url = "some.url";
  let data = "some data";

  badge.submitWriteup(ctfId, url, data, {from: account, gas: 6000000}).then(function(result) {
    console.log("Submitted Writeup!");
    console.log(result);

    let writeupEvent = findEvent("WriteupEvent", result.logs);
    console.log("ID of your writeup: " + writeupEvent.args._writeupId);
  });
}

window.approveWriteup = () => {
  let writeupId = 0;

  badge.approveWriteup(writeupId, {from: account, gas: 6000000}).then(function(result) {
    console.log("Approved Writeup!");
    console.log(result);

    let transferEvent = findEvent("Transfer", result.logs);
    console.log("ID of the token given: " + transferEvent.args._tokenId);
  });
}

window.distributeRewards = () => {
  let ctfId = 10;
  let target = account;
  let data = "U R A Winner.";
  let eth = 0;

  badge.distributeRewards(ctfId, target, data, eth, {from: account, gas: 6000000}).then(function(result) {
    console.log("Distributed Rewards!");
    console.log(result);

    let transferEvent = findEvent("Transfer", result.logs);
    console.log("ID of the token given: " + transferEvent.args._tokenId);
  });
}

var Badge = artifacts.require("Badge");
contract('Badge', function(accounts) {

  it("should submit and approve a writeup", function() {
    var badge;
    return Badge.deployed().then(function(instance) {
      badge = instance;
      return badge.registerCtf("1337 Ctf", "https://fake.com", 1, 0);
    }).then(function(r) {
      return badge.submitWriteup(0, "https://much-writeups.com", "0x41424344454647484950");
    }).then(function(r) {
      return badge.getWriteupData(0, 0);
    }).then(function(writeupData) {
      assert.equal(writeupData, "0x4142434445464748495000000000000000000000000000", "writeupData did not match expected value");
      return badge.getWriteupTeam(0, 0);
    }).then(function(writeupTeam) {
      assert.equal(writeupTeam, accounts[0], "writeupTeam did not match expected value");
      return badge.getWriteupApproved(0, 0);
    }).then(function(writeupApproved) {
      assert.equal(writeupApproved, false, "writeupApproved did not match expected value");
      return badge.approveWriteup(0, 0);
    }).then(function(r) {
      return badge.getTokenData(0);
    }).then(function(tokenData) {
      assert.equal(tokenData, "0x414243444546474849500000000000000000000000000000000000bb00000000", "tokenData did not match the expected value");
    });
  });

  it("should properly distribute a reward token", function() {
    var badge;
    return Badge.deployed().then(function(instance) {
      badge = instance;
      ctfId = 0;
      return badge.distributeRewards(ctfId.valueOf(), accounts[0], "You Win!", 0)
    }).then(function(tokenId) {
      tokenId = 1;
      return badge.getTokenData(tokenId.valueOf());
    }).then(function(tokenData) {
      assert.equal(tokenData.valueOf(), "0x596f752057696e2100000000000000000000000000000000000000aa00000000", "tokenData did not match the expected value")
    });
  });

});

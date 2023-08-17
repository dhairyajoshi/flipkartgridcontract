const supercoin = artifacts.require("SuperToken");

module.exports = function(deployer) {
  // Command Truffle to deploy the Smart Contract
  deployer.deploy(supercoin);
};
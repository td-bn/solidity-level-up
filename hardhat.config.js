require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-web3");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {version: "0.7.3"},
      {version: "0.8.6"}
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
  },
};

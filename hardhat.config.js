require('dotenv').config()

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
      {version: "0.8.7"},
      {version: "0.8.6"}
    ]
  },
  networks: {
    hardhat: {
    },
    kovan: {
      url: process.env.API,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
  },
};

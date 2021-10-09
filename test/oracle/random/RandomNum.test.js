const { ethers } = require("hardhat");
const { expect } = require("chai");

const {BigNumber} = ethers;

require('dotenv').config()

const ABI = require('./../../../artifacts/contracts/oracle/random/RandomNum.sol/RandomNum.json').abi

const RNG_CONTRACT = "0xbc9Fc9d133Afb9129a2bee12cF9Ecd6510bFA960";
const LINK = "0xa36085F69e2889c224210F603D836748e7dC0088";

describe.only('Random Number from Chainlink', () => {
  const provider = ethers.getDefaultProvider(process.env.API)
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider)
  const contract = new ethers.Contract(RNG_CONTRACT, ABI, signer)

  describe('it loads contract correclty', () => {
    it('should retreive the contract', async () => {
      expect(await contract.address).not.to.equal(ethers.constants.AddressZero)
    })
  })

  describe('getting a new random number', () => {
    it('should have a non-zero requestId after requesting a random number', async () => {
      const prevRequestId = await contract.requestId()
      const tx = await contract.getRandomNum()
      await tx.wait()
      const newRequestId = await contract.requestId()

      expect(newRequestId).not.to.equal(prevRequestId)
    })

    it('should have gotten a random number', async () => {
      expect(await contract.randomResult()).not.to.equal(BigNumber.from(0))
    })
  })
})

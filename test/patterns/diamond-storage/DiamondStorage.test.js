const { expect } = require("chai")
const { Interface } = require("ethers/lib/utils")
const { ethers } = require("hardhat")

describe('Dimaond Storage', () => {
  let diamond, facet, provider
  let alice, bob, others

  const abi = ['event SetSecret(string secret)',
    'function getTopSecret() external view returns (string memory)', 'function setTopSecret(string memory secret) external']
  const iface = new Interface(abi)

  before(async () => {
    [alice, bob, ...others] = await ethers.getSigners()
    provider = ethers.provider

    const testFacet = await ethers.getContractFactory('TestFacet')
    facet = await testFacet.connect(alice).deploy()

    const contractFactory = await ethers.getContractFactory('DiamondStorage')
    diamond = await contractFactory.connect(alice).deploy(facet.address)
  })

  describe('deployment', () => {
    it('should get deployed to non-zero addresses', () => {
      expect(facet.address).not.to.equal(ethers.constants.AddressZero)
      expect(diamond.address).not.to.equal(ethers.constants.AddressZero)
    })
  })

  describe('using a facet', () => {
    it('should set a string in storage', async () => {
      const secret = 'Hello, World!'

      const proxy = new ethers.Contract(diamond.address, abi, provider)
      let ret = await proxy.connect(bob).setTopSecret(secret)
      ret = await ret.wait()
      const value = ret.events[0].args.secret
      expect(value).to.equal(secret)
    })

    it('should retreive a string from storage', async () => {
      const secret = 'Hello, World!'

      const proxy = new ethers.Contract(diamond.address, abi, provider)
      ret = await proxy.connect(bob).getTopSecret()
      expect(ret).equals(secret)
    })
  })
})
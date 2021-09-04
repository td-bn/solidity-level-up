const { expect } = require("chai")
const { ethers } = require("hardhat")

describe('Office', () => {
  let alice, bob, charlie, others
  let instance
  let DIRECTOR_ROLE, MANAGER_ROLE

  before( async() => {
    [alice, bob, charlie, ...others] = await ethers.getSigners()

    const Office = await ethers.getContractFactory("Office")
    instance = await Office.deploy(alice.address, bob.address)

    
    DIRECTOR_ROLE = await instance.DIRECTOR_ROLE()
    MANAGER_ROLE = await instance.MANAGER_ROLE()
  })

  describe('Deployment', () => {
    it('should have a non-zero address', async () => {
      expect(instance.address).not.be.eq(ethers.constants.AddressZero)
    })

    it('should have correct default roles assigned', async () => {
      expect(await instance.hasRole(DIRECTOR_ROLE, alice.address)).to.be.true
      expect(await instance.hasRole(MANAGER_ROLE, bob.address)).to.be.true
    })
    
    it('should set correct admin role', async () => {
      expect(await instance.getRoleAdmin(MANAGER_ROLE)).to.eq(DIRECTOR_ROLE)
    })
  })

  describe('Recruiting employees', () => {
    it('should not be able to add employees if not assigned MANAGER_ROLE', async () => {
      await expect( instance.connect(charlie).addEmployee(others[0].address))
        .to.be.reverted
    })
    
    it('should add employee if MANAGER_ROLE is assigned', async () => {
      const employee = others[0].address
      await instance.connect(bob).addEmployee(employee)
      expect( await instance.activeEmployees(employee)).to.be.true
    })
  })

  describe('Recruiting managers', () => {
    it('should not allow non-directors to recruit managers', async () => {
      await expect(instance.connect(bob).addManager(charlie.address))
        .to.be.reverted
    })

    it('should allow directors to recruit managers', async () => {
      const manager = charlie.address
      await instance.connect(alice).addManager(manager)
      expect( await instance.hasRole(MANAGER_ROLE, manager)).to.be.true
    })
  })
  
  
  
})

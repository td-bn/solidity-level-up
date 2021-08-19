const { expect } = require("chai");

describe('Withdrawl', () => {

  let contract, provider;
  let alice, bob, others;

  beforeEach(async () => {
    const contractFactory = await ethers.getContractFactory('BecomeRichestWithdrawl');
    [alice, bob, ...others] = await ethers.getSigners();
    provider = ethers.provider;
    contract = await contractFactory.connect(alice).deploy({value: 100});
  })

  describe('Become Richest', () => {
    it('should deploy correctly', async () => {
      expect(contract.address).not.equals(ethers.constants.AddressZero);
      const richest = await contract.richest();
      expect(richest).equals(alice.address);
    })
  })

  describe('becomeRichest', async () => {
    it('should revert if value is less than maxAmount', async() => {
      const max = await contract.maxAmount();
      await expect(contract.becomeRichest({value: max-1}))
        .to.revertedWith("Not enough Ether")
    }) 

    it('should update richest and maxAmount', async() => {
      let richest = await contract.richest();
      expect(richest).equals(alice.address);

      await contract.connect(bob).becomeRichest({value: 300});
      richest = await contract.richest();
      const max = await contract.maxAmount();

      expect(richest).equals(bob.address);
      expect(max.toNumber()).equals(300);
    })
  })
  
  describe('withdrawl', () => {
    it('should transfer amount from contract to receiver', async() => {
      await contract.connect(bob).becomeRichest({value: 300});

      const balBefore = await provider.getBalance(contract.address);
      await contract.connect(alice).withdraw();
      const balAfter = await provider.getBalance(contract.address);

      const diff = balBefore.sub(balAfter);

      expect(diff.toString()).equals('300');
    })
  })
  
})
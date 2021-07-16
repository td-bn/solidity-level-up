const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PaymentChannel", () => {
    let paymentChannel, provider;
    let owner, alice, bob, others;

    const toWei = (eth) => ethers.utils.parseEther(eth);

    const ownerSignature = async (recepient, nonce, amount, contractAddress) => {
        const encode = ethers.utils.solidityPack;
        const encoded = encode(
            ['address', 'uint256', 'uint256', 'address'],
            [recepient, nonce, amount, contractAddress]);
        let hash = ethers.utils.keccak256(encoded);
        hash = ethers.utils.arrayify(hash);
        const sign = await owner.signMessage(hash);

        return sign;
    }

    beforeEach(async () => {
        provider = ethers.provider;
        [owner, alice, bob, ...others] = await ethers.getSigners();

        const PaymentChannel = await ethers.getContractFactory("PaymentChannel");
        paymentChannel = await PaymentChannel.connect(owner).deploy({value: toWei("5")});
    })

    describe("Deployment", () => {
        it("should get deployed properly", async () => {
            const balance = await provider.getBalance(paymentChannel.address);
            expect(balance).equals(toWei("5"));
        })
    })

    describe("Claiming", () => {
        it("should let recepient claim ether", async () => {
            const signature = await ownerSignature(alice.address, 0, toWei("1"), paymentChannel.address);
            
            const prevBalance = await provider.getBalance(alice.address);
            await paymentChannel.connect(alice).claimPayment(toWei("1"), 0, signature);
            const balance = await provider.getBalance(alice.address);

            expect(prevBalance).lt(balance);
        })

        it("should revert if claimer's address does not match address in signed message", async () => {
            const signature = await ownerSignature(alice.address, 0, toWei("1"), paymentChannel.address);
            expect(paymentChannel.connect(bob).claimPayment(toWei("1"), 0, signature))
                .to.be.revertedWith("error verifying signature");
        })
    })

    describe("Killing the contract", () => {
        it("should transfer all remaining funds to owner", async () => {
            const balance = async (address) => await provider.getBalance(address);
            const prevBalance = await balance(owner.address);
            await paymentChannel.connect(owner).kill();
            expect(await balance(owner.address)).gt(prevBalance);
            expect(await balance(paymentChannel.address)).equals(0);
        })
    })
})
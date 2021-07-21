const { ethers } = require("hardhat");
const { expect } = require("chai");
const { time } = require("@openzeppelin/test-helpers");

const MONTHLY = 60 * 60 * 24 * 30;

describe("Subscription Service", () => {
    let service;
    let owner, merchant, subscriber, others;
    let token;

    const createPlan = async () => 
        await service.connect(merchant).createPlan(token.address, MONTHLY.toString(), 100);
    
    const createSubscription = async () => {
        await createPlan();
        await token.connect(subscriber).approve(service.address, 500);
        await service.connect(subscriber).subscribe(0)
    }

    beforeEach(async () => {
        const SubscriptionService = await ethers.getContractFactory("SubscriptionService");
        const SampleToken = await ethers.getContractFactory("SampleToken");
        [owner, merchant, subscriber, ...others] = await ethers.getSigners();
        service = await SubscriptionService.connect(owner).deploy();
        token = await SampleToken.deploy();
        await token.transfer(subscriber.address, 1000);
    })

    describe("Deployment", () => {
        it("should deploy the contract", async () => {
            expect(service.address).not.to.equal(ethers.constants.AddressZero);
        })
    })

    describe("Adding plans", () => {
        it("should add a plan if is a valid plan", async () => {
            await service.connect(merchant).createPlan(token.address, MONTHLY.toString(), 100);

            const plan = await service.plans(0);
            expect(plan.frequency).equals(MONTHLY.toString());
            expect(plan.token).equals(token.address);
            expect(plan.cost).equals(100);
            expect(plan.merchant).equals(merchant.address);
        })

        it("should fail if token address is invalid", async () => {
            await expect(service.connect(merchant).createPlan(ethers.constants.AddressZero, MONTHLY.toString(), 100))
                .to.revertedWith("invalid ERC token")
        })

        it("should fail if frequency is invalid", async () => {
            await expect(service.connect(merchant).createPlan(token.address, 0, 100))
                .to.revertedWith("frequency needs to be positive")
        })

        it("should fail if cost is invalid", async () => {
            await expect(service.connect(merchant).createPlan(token.address, MONTHLY, 0))
                .to.revertedWith("cost needs to be positive")
        })
    })

    describe("Subscribing to plans", () => {
        it("should subscribe a user to a plan", async () => {
            await createPlan();
            await token.connect(subscriber).approve(service.address, 500);

            await expect(service.connect(subscriber).subscribe(0))
                .to.emit(service, "Transfer");
            
            const subscription = await service.subscriptions(subscriber.address, 0);
            expect(subscription.user).equals(subscriber.address);
        })

        it("should fail if no such plan exists", async () => {
            await token.connect(subscriber).approve(service.address, 500);

            await expect(service.connect(subscriber).subscribe(0))
                .to.be.revertedWith("no such plan exists");
        })
    })

    describe("Cancelling a plan", () => {
        it("should cancel an existing plan", async () => {
            await createSubscription();
            await expect(service.connect(subscriber).cancel(0))
                .to.emit(service, "Cancel")
                .withArgs(subscriber.address, 0);
        })

        it("should revert if no such subscription exists", async () => {
            await expect(service.connect(subscriber).cancel(0))
                .to.be.revertedWith("invalid subscription");
        })
    })

    describe("Payments", () => {
        it("should go through if they are due", async () => {
            await createSubscription();
            await time.increase(MONTHLY + 1);
            await expect(service.connect(others[0]).pay(subscriber.address, 0))
                .to.emit(service, "Transfer")
                .withArgs(subscriber.address, 0);
        })

        it("should fail if they are not due", async () => {
            await createSubscription();
            await time.increase(MONTHLY - 1);
            await expect(service.connect(others[0]).pay(subscriber.address, 0))
                .to.revertedWith("payment not due yet");
        })
    })
})
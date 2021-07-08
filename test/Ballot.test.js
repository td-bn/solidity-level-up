const {expect} = require("chai");

const toBytes32 = (str) => ethers.utils.formatBytes32String(str);
const add = (str, num) => ethers.BigNumber.from(str).add(ethers.BigNumber.from(num));

describe("Ballot contract", function() {
    
    let ballot;
    let owner;
    let others;

    beforeEach(async function () {
        const Ballot = await ethers.getContractFactory("Ballot");
        [owner, ...others] = await ethers.getSigners();

        // Proposal names
        const names = ["July", "August", "September"];
        const proposalNames = names.map( (name) => toBytes32(name));

        ballot = await Ballot.deploy(proposalNames);
    });

    describe("Deployement", () => {
        it("Should deploy correctly", async () => {
            expect((await ballot.proposals(0)).name).equals(toBytes32("July"));
        });
    });

    describe("Delegation of voting", () => {
        it("should not delegate vote if voter has voted", async () => {
            const [alice, bob] = others;
            let Alice, Bob;

            await ballot.connect(alice).vote(0);

            await expect(
                ballot.connect(alice).delegate(bob.address)
            ).to.be.revertedWith("voter has already voted");
        })

        it("should delegate vote if voter has not voted", async () => {
            const [alice, bob] = others;
            let Alice, Bob;

            await ballot.connect(alice).delegate(bob.address);

            Alice = await ballot.voters(alice.address);
            Bob = await ballot.voters(bob.address);

            expect(Alice.voted).equals(true);
            expect(Bob.weight).equals(2);
            expect(Alice.delegate).equals(bob.address);
        })

        it("should cast vote if delegete has voted and voter has not voted", async () => {
            const [alice, bob] = others;
            let Alice, Bob;

            await ballot.connect(bob).vote(0);

            const countBefore = (await ballot.proposals(0)).voteCount;
            await ballot.connect(alice).delegate(bob.address);
            const countAfter= (await ballot.proposals(0)).voteCount;

            Alice = await ballot.voters(alice.address);
            Bob = await ballot.voters(bob.address);

            expect(Alice.voted).equals(true);
            expect(Bob.weight).equals(1);
            expect(Alice.delegate).equals(bob.address);
            expect(countAfter).equals(add(countBefore, Alice.weight));
        });
    });

    describe("Voting", () => {
        it("should change voting status after vote is casted", async () => {
            const [alice] = others;
            await ballot.connect(alice).vote(0);
            let Alice = await ballot.voters(alice.address);
            expect(Alice.voted).equals(true);
        });

        it("should not allow duplicate votes", async () => {
            const [alice] = others;
            await ballot.connect(alice).vote(0);
            let Alice = await ballot.voters(alice.address);

            await expect(
                ballot.connect(alice).vote(0)
            ).to.be.revertedWith("voter has already voted");
        })        
    });

    describe("Results", () => {
        it("should declare the winner correctly", async () => {
            const [alice, bob, cam, dick] = others;

            // Proposal names
            // ["July", "August", "September"];
 
            // Voting
            await ballot.connect(alice).vote(0);
            await ballot.connect(bob).vote(1);
            await ballot.connect(cam).vote(2);
            await ballot.connect(dick).vote(1);

            const winningProposal = await ballot.winningProposal();
            expect(winningProposal).equals(toBytes32("August"));
        });
    });
});
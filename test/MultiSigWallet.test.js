const { expect } = require("chai");

describe("Multi Signature Wallet", () => {
    let owner, wallet, others;
    let alice, bob, chuck;
    let addresses, balance;
    let provider;
    
    const toEther = (valueInWei) => ethers.utils.formatEther(valueInWei);
    const toWei = (valueInEther) => ethers.utils.parseEther(valueInEther);

    const deposit = (eth) => chuck.sendTransaction( {
        to: wallet.address,
        value: toWei(eth)
    });

    const createTransaction = (amount) => {
        wallet.connect(owner).submitTx(chuck.address, toWei(amount))
        return 0;
    }

    beforeEach( async () => {
        const MSW = await ethers.getContractFactory("MultiSigWallet");
        [owner, alice, bob, chuck, ...others] = await ethers.getSigners();

        // Harhat ethers plugin provides a custom provider
        provider = ethers.provider;

        addresses = [owner.address, alice.address, bob.address];
        wallet = await MSW.deploy(addresses, 2);
    });

    describe("Deployement", () => {
        it("should deploy correctly", async () => {

            for (let i=0; i<3; i++) {
                const address = await wallet.owners(i);
                expect(address).to.equal(addresses[i]);
            }
            const numConfirmations = await wallet.numConfirmations();
            expect(numConfirmations).to.equal(2);
        });
    });

    describe("Deposits", () => {
        it("increase the balance of the contract", async () => {
            balance = await provider.getBalance(wallet.address);
            expect(toEther(balance)).equals("0.0");

            await expect(deposit("1.0"))
                .to.emit(wallet, 'Deposit')
                .withArgs(chuck.address, toWei("1.0"), toWei("1.0"));

            balance = await provider.getBalance(wallet.address);
            expect(toEther(balance)).equals("1.0");
        });
    });

    describe("Creating transactions", () => {
        it("should revert if address is incorrect", async () => {
            await deposit("3.0");

            await expect(wallet.submitTx(ethers.constants.AddressZero, toWei("1.0")))
                .to.be.revertedWith("invalid address");
        });

        it("should revert if funds are insufficient", async () => {
            await deposit("3.0");
            const amount = toWei("5.0");

            await expect(wallet.submitTx(chuck.address, amount))
                .to.be.revertedWith("not enough funds in contract");
        });


        it("should add a transaction to the list of transactions", async () => {
            await deposit("3.0");
            const amount = toWei("2.0");

            await expect(wallet.connect(owner).submitTx(chuck.address, amount))
                .to.emit(wallet, "Submit")
                .withArgs(chuck.address, owner.address, amount, 0);

            const transaction = await wallet.transactions(0);
            expect(transaction.executed).equals(false);
            expect(transaction.confirmationCount).equals(1);
        });
    });

    describe("Confirmation", () => {
        it("should reject if the sender is not an owner", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");

            await expect(wallet.connect(chuck).confirmTx(index))
                .to.be.revertedWith("only owners can trigger this action");
        })

        it("should reject if transaction is not valid", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");

            await expect(wallet.connect(owner).confirmTx(index+1))
                .to.be.revertedWith("index not valid");
        })

        it("confirms a valid transaction and increases confirmationCount", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transaction;

            transaction = await wallet.transactions(0);
            expect(transaction.confirmationCount).equals(1);

            await expect(wallet.connect(alice).confirmTx(index))
                .to.emit(wallet, "Confirm")
                .withArgs(alice.address, index);

            transaction = await wallet.transactions(0);
            expect(transaction.confirmationCount).equals(2);
        });

        it("does not allow duplicate confirmations", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transaction;

            await wallet.connect(alice).confirmTx(index);

            await expect(wallet.connect(alice).confirmTx(index))
                .to.be.revertedWith("you have already confirmed");
        });
    })

    describe("Revocation", () => {
        it("should reject if the sender is not an owner", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");

            await expect(wallet.connect(chuck).revokeConfirmation(index))
                .to.be.revertedWith("only owners can trigger this action");
        })

        it("should reject if transaction is not valid", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");

            await expect(wallet.connect(owner).revokeConfirmation(index+1))
                .to.be.revertedWith("index not valid");
        })

        it("revokes a valid transaction and decreases confirmationCount", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transaction;

            transaction = await wallet.transactions(0);
            expect(transaction.confirmationCount).equals(1);

            await wallet.connect(alice).confirmTx(index);

            transaction = await wallet.transactions(0);
            expect(transaction.confirmationCount).equals(2);

            await expect(wallet.connect(alice).revokeConfirmation(index))
                .to.emit(wallet, "Revoke")
                .withArgs(alice.address, index);

            transaction = await wallet.transactions(0);
            expect(transaction.confirmationCount).equals(1);
       });

        it("does not allow duplicate revocations", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transaction;

            await wallet.connect(alice).confirmTx(index);
            await wallet.connect(alice).revokeConfirmation(index);

            await expect(wallet.connect(alice).revokeConfirmation(index))
                .to.be.revertedWith("you haven't confirmed this transaction");
        });
    })

    describe("Transaction execution", () => {
        it("should fail if sender is not an owner", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transction;

            await wallet.connect(alice).confirmTx(index);

            expect( wallet.connect(chuck).execute(index))
                .to.be.revertedWith("only owners can trigger this action");
        });

        it("should fail if transaction is not valid", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transction;

            await wallet.connect(alice).confirmTx(index);

            expect( wallet.connect(alice).execute(index+1))
                .to.be.revertedWith("index not valid");
        });

        it("should fail if number of confirmations is lower than required number of confirmations", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transction;

            expect( wallet.connect(alice).execute(index))
                .to.be.revertedWith("not enough confirmations");
        });

        it("should execute transaction", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transction;

            await wallet.connect(alice).confirmTx(index);

            expect( wallet.connect(alice).execute(index))
                .to.emit(wallet, "Execute")
                .withArgs(alice.address, index);
            
            transaction = await wallet.transactions(index);
            expect(transaction.executed).equals(true);
        });

        it("should not execute already executed transaction", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");
            let transction;

            // Execute once
            await wallet.connect(alice).confirmTx(index);
            await wallet.connect(alice).execute(index);
            
            expect(wallet.connect(alice).execute(index))
                .to.be.revertedWith("transaction already executed");
        });

        it("should decrease wallet balance and increse sendee balance", async () => {
            await deposit("3.0");
            const index = createTransaction("1.0");

            const initialBalanceWallet = await provider.getBalance(wallet.address);
            const initialBalanceChuck = await provider.getBalance(chuck.address);

            // Confirm and execute
            await wallet.connect(alice).confirmTx(index);
            await wallet.connect(alice).execute(index);
              
            balance = await provider.getBalance(wallet.address);
            expect(balance).to.be.lt(initialBalanceWallet);


            balance = await provider.getBalance(chuck.address);
            expect(balance).to.be.gt(initialBalanceChuck);
        });
    })

});
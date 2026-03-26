import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that a user can initialize a proposal and cast a vote",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        // Get pre-defined accounts
        const deployer = accounts.get("deployer")!;
        const voter1 = accounts.get("wallet_1")!;

        // Block 1: Initialize the voting proposal
        let block = chain.mineBlock([
            Tx.contractCall(
                "blockchain-voting", 
                "add-proposal", 
                [types.utf8("Election 2026"), types.uint(100)], 
                deployer.address
            )
        ]);
        
        // Assert proposal was added successfully
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        block.receipts[0].result.expectOk().expectBool(true);

        // Block 2: Cast a vote
        block = chain.mineBlock([
            Tx.contractCall(
                "blockchain-voting",
                "vote",
                [types.uint(0)], // voting for proposal ID 0
                voter1.address
            )
        ]);

        // Assert vote was recorded
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 3);
        block.receipts[0].result.expectOk().expectBool(true);
    },
});

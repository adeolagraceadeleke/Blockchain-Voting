import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that a user cannot vote twice for the same proposal",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const voter1 = accounts.get("wallet_1")!;
        const proposalId = types.uint(0);

        // 1. Setup: Add a proposal
        let block = chain.mineBlock([
            Tx.contractCall(
                "blockchain-voting", 
                "add-proposal", 
                [types.utf8("Election 2026"), types.uint(100)], 
                deployer.address
            )
        ]);
        
        // 2. First Vote: Should succeed
        block = chain.mineBlock([
            Tx.contractCall(
                "blockchain-voting",
                "vote",
                [proposalId],
                voter1.address
            )
        ]);
        block.receipts[0].result.expectOk().expectBool(true);

        // 3. Second Vote: Should fail (Duplicate Vote)
        block = chain.mineBlock([
            Tx.contractCall(
                "blockchain-voting",
                "vote",
                [proposalId],
                voter1.address
            )
        ]);

        // Assert that the second vote returns an error (e.g., err u101 for 'already-voted')
        // Replace 101 with the specific error code defined in your .clar contract
        block.receipts[0].result.expectErr().expectUint(101);
    },
});

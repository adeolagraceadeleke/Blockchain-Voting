📘 README

Blockchain-Voting Smart Contract

A transparent and decentralized voting system for local communities, built on the Stacks blockchain. This contract allows community members to create proposals, cast votes, and view results on-chain, ensuring transparency, security, and immutability of decisions.

✨ Features

Proposal Creation: Any user can create a proposal with a title, description, and voting duration.

Voting: Community members can cast a yes or no vote once per proposal.

Immutable Records: Votes are permanently recorded on-chain and cannot be altered.

Automatic Closing: Proposals are open for a defined duration and automatically close after the set block height.

Results Transparency: Anyone can view the proposal details, vote status, and results.

⚙️ Data Structures

Proposals Map: Stores details of each proposal (title, description, proposer, vote counts, deadline, execution status).

Votes Map: Tracks votes from individual participants per proposal.

Data Variable: next-proposal-id increments with every new proposal.

📖 Public Functions

(create-proposal title description duration)
Creates a new proposal with the provided details. Returns the proposal ID.

(cast-vote proposal-id vote)
Casts a vote (true for yes, false for no) on a given proposal. Prevents duplicate votes and disallows voting after the deadline.

📖 Read-Only Functions

(get-proposal proposal-id) → Returns proposal details.

(get-vote proposal-id voter) → Returns a voter’s recorded choice.

(get-proposal-results proposal-id) → Returns total votes, yes/no counts, and whether the proposal has ended.

(get-next-proposal-id) → Returns the ID for the next proposal.

🚨 Errors

err-owner-only (u100) – Restricted to contract owner only (if extended later).

err-not-found (u101) – Proposal not found.

err-already-voted (u102) – Voter has already voted.

err-voting-ended (u103) – Voting period has ended.

err-voting-not-ended (u104) – Voting still ongoing (for future execution logic).

🛠️ Example Workflow

A community member creates a proposal:

(contract-call? .blockchain-voting create-proposal "Community Park Renovation" "Should we allocate funds to renovate the park?" u500)


Members cast votes:

(contract-call? .blockchain-voting cast-vote u0 true)  ;; Vote YES on proposal 0
(contract-call? .blockchain-voting cast-vote u0 false) ;; Vote NO on proposal 0


Anyone checks results:

(contract-call? .blockchain-voting get-proposal-results u0)
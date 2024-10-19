# StealthBid - Contracts

## Contracts Overview

### 1. **JobProposal.sol**
The `JobProposal` contract manages the creation and handling of job proposals, budget reveals, and voting. The proposal process is divided into several phases: 

- **Submission Phase**: The DAO submits a job proposal and workers apply with encrypted budgets.
- **Reveal Phase**: Once submissions close, the encrypted budgets are revealed.
- **Voting Phase**: DAO members stake governance tokens to vote for the best worker submission.
- **Execution Phase**: The winning worker is selected, and the proposal is executed.

Key Features:
- **Budget Submission and Reveal**: Both DAO and workers submit encrypted budgets, which are revealed later to ensure fairness.
- **Voting**: Stakeholders vote for worker submissions by staking governance tokens.
- **Escrow**: Tokens are held in escrow and released upon task completion.

### 2. **ApplicationSubmission.sol**
The `ApplicationSubmission` contract manages worker applications for a job proposal. Workers submit their details and encrypted budgets during the submission phase, and these details are processed and voted on during the proposal execution.

Key Features:
- **Worker Applications**: Allows workers to submit their applications with encrypted budgets.
- **Budget Validation**: Sets the budget during the reveal phase if it falls within the proposal’s budget range.
- **Voting Mechanism**: Accepts votes from the `JobProposal` contract and tracks each worker's votes.
- **Application Acceptance**: The contract marks a worker’s application as accepted once the proposal execution is finalized.

## Technical Stack
- **Solidity**: Core smart contracts.
- **Chainlink Functions**: Used to integrate off-chain budget reveal and voting mechanisms.
- **OpenZeppelin ERC-20**: For handling governance token transfers and staking.
  
## Key Components:
1. **Submit-Reveal Scheme**: Prevents manipulation by hiding the budgets of the DAO and workers until the reveal phase.
2. **Voting and Staking**: Uses ERC-20 governance tokens for voting on the most suitable worker submissions.
3. **Escrow System**: Ensures the allocated budget is held securely and released upon task completion.

### Example Workflow:
1. DAO creates a proposal with an encrypted budget.
2. Workers submit applications with their encrypted budgets.
3. Budgets are revealed using Chainlink oracle services.
4. DAO members vote on the best submission.
5. The winning worker is selected, and funds are disbursed after successful task completion.

### Events
- `Voted`: Emitted when a vote is cast.
- `TokensStaked`: Emitted when tokens are staked for voting.
- `ApplicationSubmitted`: Emitted when a worker submits an application.
- `ApplicationAccepted`: Emitted when a worker’s submission is accepted.

## Deployment and Testing
- Contracts should be deployed on Ethereum-compatible networks (e.g., Ethereum, Polygon).
- Chainlink oracle services should be properly configured for the reveal process.
  
## Future Enhancements
- **Reputation System**: Implement a system to track and reward worker performance.
- **Dynamic Pricing**: Introduce features that allow workers to adjust their budget offers based on task difficulty. 
- **Layer 2 Scaling**: Use Layer 2 solutions for cheaper and faster transactions.
---
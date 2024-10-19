# **DAO Task Allocation System - Privacy-Preserving Negotiation**

## **Description**

This system facilitates job market or task allocation for Decentralized Autonomous Organizations (DAOs) using a **submit-reveal scheme**. The purpose is to ensure fairness by preventing either party (the DAO or the worker) from knowing the other's budget or offer during the initial submission phase. By introducing **privacy-preserving negotiation**, this system enhances fairness in task allocation and selection.

### **Key Components of the System**

1. **DAO Proposal for Work**
   - **Proposal Submission**: DAOs submit task or project proposals without revealing the budget.
   - **Task Details**: Describes the work, required skills, deadlines, and specifications (excluding the budget).
   - **Hidden Budget**: The DAO’s budget remains hidden until the reveal phase.

2. **Worker Offers**
   - **Offer Submission**: Workers submit offers including their qualifications, timeframes, and a hidden budget (price to complete the task).
   - **Hidden Offer**: Worker budgets are also encrypted and hidden until the reveal phase.

3. **Submit-Reveal Process**
   - **Submission Phase**: Both the DAO and workers submit their encrypted budgets.
   - **Reveal Phase**: After a predetermined time, both budgets are revealed simultaneously using a smart contract.
   - **Reveal Mechanism**: Ensures neither party gains an unfair advantage by seeing the other’s offer beforehand.

4. **Match and Task Allocation**
   - **Budget Comparison**: Once revealed, the smart contract compares the DAO's budget with worker offers.
   - **Task Assignment**: The system eliminates workers whose offers are not close to the DAO’s budget, and a voting process starts for final task assignment.

5. **Execution and Payment**
   - **Escrow System**: The DAO's budget is placed in escrow, and the worker is paid upon successful task completion and verification.
   - **Dispute Resolution**: Optional dispute resolution can be integrated via decentralized juries or automated rules.

---

## **Technical Stack and Architecture**

### **1. Blockchain Layer (Smart Contracts)**
- **Ethereum/Polygon**: Built on Ethereum or EVM-compatible chains (e.g., Polygon) for decentralized security and efficient transaction management.
- **Smart Contracts**: Written in Solidity to handle:
   - Proposal submission (encrypted budgets and timestamps)
   - The reveal process (time-locked simultaneous reveal)
   - Task assignment logic
   - Escrow and payment management

### **2. Cryptographic Techniques**
- **Shutter Network**: To ensure budgets remain private until the reveal phase.
### **3. Decentralized storage**
- **Walrus**: Job proposal metadata is persisted on the walrus decentralized storage .
### **4. Frontend (User Interface)**
- **React.js**: Provides a responsive interface for DAOs and workers.
- **Ethers.js**: Integrates blockchain functionality to interact with smart contracts.
- **Metamask**: Enables wallet integration for task and offer submissions.

---

## **Potential Challenges and Solutions**

1. **Incentivizing Participation**
   - Implement a staking mechanism to prevent frivolous proposals and offers, requiring both parties to lock tokens as a commitment to the process.

2. **Task Quality and Verification**
   - Use decentralized oracles (e.g., Chainlink) for task verification, or develop a reputation system to evaluate worker performance.

---

## **Enhancements and Future Work**

- **Reputation System**: Implement a decentralized system that rewards workers for successful tasks and penalizes disputes or failures.
- **Dynamic Pricing**: Enable dynamic budget adjustments based on task difficulty before the reveal phase ends.
- **Layer 2 Scaling**: Consider Layer 2 solutions like Optimism or zkSync for lower transaction costs and better scalability.
- **Implementing the escrow**: Give payouts to the accepted submission 
with the help of smart contracts.
---

## **Getting Started**

### **Prerequisites**
- Ethereum wallet (e.g., MetaMask)
- [Foundry](https://book.getfoundry.sh/getting-started/installation) (for contract compilation and testing)
- [Node.js](https://nodejs.org/en/) (for API interactions)

### **Installation**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/dao-task-allocation.git
   cd dao-task-allocation
   ```

2. **Install dependencies:**
   ```bash
   forge install
   ```

3. **Compile the smart contracts:**
   ```bash
   forge build
   ```

4. **Run tests:**
   ```bash
   forge test
   ```

---

## **Usage**

1. **Submit Encrypted Proposal/Offer**:
   - DAOs and workers submit their encrypted budgets using the `submit()` function.
   
2. **Reveal Budgets**:
   - After the submission phase, both parties reveal their budgets through the `reveal()` function.

3. **Task Assignment**:
   - A smart contract automatically compares the budgets and assigns the task accordingly.

---
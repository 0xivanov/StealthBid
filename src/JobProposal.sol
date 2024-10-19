// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/v0.8/functions/v1_0_0/FunctionsClient.sol";
import "@chainlink/contracts/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import "./ApplicationSubmission.sol";

/**
  * @title JobProposal
  * @notice This contract is used to create a job proposal.
  It handles the reveal of the budgets, voting, and execution of the proposal.
 */
contract JobProposal is FunctionsClient {
    using Strings for uint256;
    using FunctionsRequest for FunctionsRequest.Request;

    // State
    bytes32 public s_lastRequestId;
    // Encoded uint8 array of budgets - to be revealed by the oracle at the start of the voting phase
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Job proposal details
    string public description;
    // Job proposal creator
    address public creator;
    // Address of the application submission contract
    address public applicationSubmissionAddress;
    // Encrypted budget
    string public encrypted_budget;
    // Actual budget in usd/hour - will be revealed at the start of the voting phase
    uint8 public budget;
    // Submission phase end timestamp
    uint public submission_phase_end_timestamp;
    // Voting phase end timestamp
    uint public voting_phase_end_timestamp;
    // Flag to indicate if the proposal has been executed
    bool public executed;
    // The address of the ERC20 token used for governance
    IERC20 public governanceToken;

    // Structures to track votes
    mapping(address => bool) public votes;
    address[] public voteAddresses;
    // Structure to track the staked tokens
    mapping(address => uint) public stakedTokens;

    // Events
    event Voted(address voter, address submitter, uint weight);
    event TokensStaked(address voter, uint amount);
    event TokensUnstaked(address voter, uint amount);
    event Response(bytes32 indexed requestId, bytes response, bytes err);

    // Errors
    error AlreadyVoted();
    error OnlyCreator();
    error InsufficientTokens();
    error TransferFailed();
    error ProposalAlreadyExecuted();
    error BudgetAlreadyRevealed();
    error SubmissionPeriodNotOver();
    error VotingPeriodOver();
    error VotingPeriodNotStarted();
    error ExecutionPeriodNotStarted();
    error UnexpectedRequestID(bytes32 requestId);

    modifier hasNotVoted() {
        if (votes[msg.sender]) revert AlreadyVoted();
        _;
    }

    modifier onlyCreator() {
        if (msg.sender != creator) revert OnlyCreator();
        _;
    }

    constructor(
        string memory _description,
        string memory _encrypted_budget,
        uint _submission_phase_end_timestamp,
        uint _voting_phase_end_timestamp,
        address _creator,
        address _applicationSubmissionAddress,
        IERC20 _token
    )
        // hardcoded for Ethereum Sepolia
        FunctionsClient(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0)
    {
        creator = _creator;
        applicationSubmissionAddress = _applicationSubmissionAddress;
        description = _description;
        encrypted_budget = _encrypted_budget;
        governanceToken = _token;
        submission_phase_end_timestamp = _submission_phase_end_timestamp;
        voting_phase_end_timestamp = _voting_phase_end_timestamp;
    }

    /**
     * @notice Start the reveal of the budgets. This function will send a request to the oracle 
       and the budgets will be revealed in the fulfillRequest function as a callback.
     * @param source JavaScript source code
     * @param subscriptionId Billing ID
     * @param gasLimit Gas limit for the oracle call
     * @param donID ID of the job to be invoked
     */
    function startRevealOfBudgets(
        string memory source,
        uint64 subscriptionId,
        uint32 gasLimit,
        bytes32 donID
    ) public onlyCreator returns (bytes32 requestId) {
        if (budget > 0) revert BudgetAlreadyRevealed();
        // if (block.timestamp < submission_phase_end_timestamp)
        //     revert SubmissionPeriodNotOver();

        // Get the encrypted budgets of all the applicants
        ApplicationSubmission.Application[]
            memory applications = ApplicationSubmission(
                applicationSubmissionAddress
            ).getApplications();
        string[] memory args = new string[](applications.length + 2);
        args[0] = submission_phase_end_timestamp.toString();
        args[1] = encrypted_budget;
        for (uint i = 0; i < applications.length; i++) {
            args[i + 2] = applications[i].encrypted_budget;
        }

        // Send the request to the oracle with the encrypted budgets and timestamp
        requestId = _sendRequestToOracle(
            source,
            args,
            subscriptionId,
            gasLimit,
            donID
        );
    }

    /**
     * @notice Reveal the budgets. This function will be called by creator after the oracle has revealed the budgets.
      The s_lastResponse from the fulfillRequest will be decoded off chain and the budgets will be set.
     */
    function setBudgets(uint8[] memory _budgets) public onlyCreator {
        // if (block.timestamp < voting_phase_end_timestamp)
        //     revert VotingPeriodNotStarted();
        // if (block.timestamp > voting_phase_end_timestamp)
        //     revert VotingPeriodOver();

        budget = _budgets[0];
        ApplicationSubmission(applicationSubmissionAddress).setBudgets(
            _budgets
        );
    }

    /**
     * @notice Vote for an application. This function will be called by the voters to vote for an application.
     * @param submitter The address of the applicant
     * @param amount The number of tokens to stake
     */
    function vote(address submitter, uint amount) public hasNotVoted {
        // if (executed) revert ProposalAlreadyExecuted();
        // if (block.timestamp < submission_phase_end_timestamp)
        //     revert VotingPeriodNotStarted();
        // if (block.timestamp > voting_phase_end_timestamp)
        //     revert VotingPeriodOver();

        uint voterBalance = governanceToken.balanceOf(msg.sender);
        if (voterBalance < amount) revert InsufficientTokens();

        // TODO
        //       Transfer the tokens to the contract (staking)
        // bool success = governanceToken.transferFrom(
        //     msg.sender,
        //     address(this),
        //     amount
        // );
        // if (!success) revert TransferFailed();

        ApplicationSubmission(applicationSubmissionAddress).voteForApplication(
            submitter,
            amount
        );
        stakedTokens[msg.sender] = amount;

        votes[msg.sender] = true;
        voteAddresses.push(msg.sender);

        emit Voted(msg.sender, submitter, voterBalance);
        emit TokensStaked(msg.sender, voterBalance);
    }

    /**
     * @notice Execute the proposal. This function will be called by the creator after the voting period is over.
      It will check the votes and accept the application with the highest votes and return the staked tokens.
     */
    function execute() public onlyCreator {
        if (executed) revert ProposalAlreadyExecuted();
        // if (block.timestamp < voting_phase_end_timestamp)
        //     revert ExecutionPeriodNotStarted();

        // Check votes
        ApplicationSubmission.Application[]
            memory applications = ApplicationSubmission(
                applicationSubmissionAddress
            ).getApplications();
        uint256 highestVoteCount = 0;
        address winningApplicant;
        for (uint i = 0; i < applications.length; i++) {
            if (applications[i].votes > highestVoteCount) {
                highestVoteCount = applications[i].votes;
                winningApplicant = applications[i].applicant;
            }
        }

        // Accept the winning application
        ApplicationSubmission(applicationSubmissionAddress).acceptApplication(
            winningApplicant
        );

        // Unstake the tokens (return them to voters)
        for (uint i = 0; i < voteAddresses.length; i++) {
            address voter = voteAddresses[i];
            uint amount = stakedTokens[voter];
            if (amount > 0) {
                // TODO
                // governanceToken.transfer(voter, amount);
                emit TokensUnstaked(voter, amount);
            }
        }

        executed = true;
    }

    function _sendRequestToOracle(
        string memory source,
        string[] memory args,
        uint64 subscriptionId,
        uint32 gasLimit,
        bytes32 donID
    ) private returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        if (args.length > 0) req.setArgs(args);
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }
        s_lastResponse = response;
        s_lastError = err;
        emit Response(requestId, s_lastResponse, s_lastError);
    }

    function getProposalDetails()
        public
        view
        returns (string memory, address, uint, uint, bool)
    {
        return (
            description,
            creator,
            budget,
            submission_phase_end_timestamp,
            executed
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./JobProposal.sol";

/**
 * @title ApplicationSubmission
 * @notice This contract handles the state of submission of applications for a job proposal.
 */
contract ApplicationSubmission {
    // State
    address public proposalAddress;

    // Track applications
    mapping(address => Application) public applications;
    address[] public applicants;

    // Events
    event ApplicationSubmitted(
        address indexed applicant,
        string encrypted_budget
    );
    event ApplicationAccepted(address indexed applicant);

    // Errors
    error ApplicationAlreadyExists();
    error ApplicationDoesNotExist();
    error SubmissionPeriodOver();
    error InvalidPermissions();
    error InvalidVote();

    struct Application {
        address applicant;
        string applicant_description;
        string encrypted_budget;
        uint budget;
        uint votes;
        bool isAccepted; // If true - the application has been accepted
    }

    modifier onlyProposal() {
        if (msg.sender != proposalAddress) revert InvalidPermissions();
        _;
    }

    // Set the address of the proposal contract after deployment
    function setProposalAddress(address _proposalAddress) public {
        if (proposalAddress != address(0)) revert InvalidPermissions();
        proposalAddress = _proposalAddress;
    }

    /**
      * @notice Set the budgets for the applicants. This function can only be called by the proposal contract
      and only during the reveal phase. 
      Any applicant who has submitted a budget within 10% of the proposal budget will have their budget set.
     */
    function setBudgets(uint8[] memory budgets) external onlyProposal {
        uint8 proposalBudget = budgets[0];
        for (uint i = 1; i < applicants.length; i++) {
            if (
                (budgets[i] < ((proposalBudget * 110) / 100)) &&
                (budgets[i] > ((proposalBudget * 9) / 10))
            ) {
                // set the budget only for the applicants who have submitted a budget
                // within 10% of the proposal budget
                applications[applicants[i]].budget = budgets[i];
            }
        }
    }

    /**
     * @notice Submit an application for the proposal. This function can only be called during the submission phase.
     */
    function submitApplication(
        string memory _encrypted_budget,
        string memory _applicant_description
    ) external {
        if (applications[msg.sender].applicant != address(0))
            revert ApplicationAlreadyExists(); // Ensure the user hasn't already submitted an application

        // if (
        //     block.timestamp >
        //     Proposal(proposalAddress).submission_phase_end_timestamp()
        // ) revert SubmissionPeriodOver(); // Ensure the submission period is not over

        // Create the application
        applications[msg.sender] = Application({
            applicant: msg.sender,
            applicant_description: _applicant_description,
            encrypted_budget: _encrypted_budget,
            budget: 0,
            votes: 0,
            isAccepted: false
        });

        applicants.push(msg.sender);
        emit ApplicationSubmitted(msg.sender, _encrypted_budget);
    }

    /**
     * @notice Vote for an application. This function can only be called by the proposal contract.
     */
    function voteForApplication(
        address applicant,
        uint votingPower
    ) public onlyProposal {
        Application storage application = applications[applicant];
        if (application.budget == 0) revert InvalidVote();
        application.votes += votingPower;
    }

    /**
     * @notice Marks an application as accepted. This function can only be called by the proposal contract.
     */
    function acceptApplication(address _applicant) external onlyProposal {
        if (applications[_applicant].applicant == address(0))
            revert ApplicationDoesNotExist(); // Check if the application exists

        // Accept the application
        applications[_applicant].isAccepted = true;
        emit ApplicationAccepted(_applicant);
    }

    function getApplications() external view returns (Application[] memory) {
        Application[] memory userApplications = new Application[](
            applicants.length
        );
        for (uint i = 0; i < applicants.length; i++) {
            userApplications[i] = applications[applicants[i]];
        }
        return userApplications;
    }
}

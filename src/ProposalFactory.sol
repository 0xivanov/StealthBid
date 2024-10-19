// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./JobProposal.sol";
import "./ApplicationSubmission.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ProposalFactory
 * @notice This contract is used to create a new job proposal.
 */
contract ProposalFactory {
    // State
    JobProposal[] public proposals;

    // Events
    event ProposalCreated(address proposalAddress, address creator);

    // Create a new cloned Proposal contract
    function createProposal(
        string memory _description,
        string memory _encrypted_budget,
        uint _submission_phase_end_timestamp,
        uint _voting_phase_end_timestamp,
        IERC20 _token
    ) public {
        ApplicationSubmission applicantionSubmission = new ApplicationSubmission();

        JobProposal proposal = new JobProposal(
            _description,
            _encrypted_budget,
            _submission_phase_end_timestamp,
            _voting_phase_end_timestamp,
            msg.sender,
            address(applicantionSubmission),
            _token
        );
        applicantionSubmission.setProposalAddress(address(proposal));

        proposals.push(proposal);
        emit ProposalCreated(address(proposal), msg.sender);
    }

    function getAllProposals() public view returns (JobProposal[] memory) {
        return proposals;
    }
}

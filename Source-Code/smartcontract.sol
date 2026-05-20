// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatentChainIN {
    
    address public admin;
    uint public proposalCount;

    struct Patent {
        uint id;
        string title;
        address applicant;
        uint votesFor;
        uint votesAgainst;
        bool approved;
        bool exists;
    }

    mapping(uint => Patent) public patents;
    mapping(address => bool) public isExaminer;
    mapping(uint => mapping(address => bool)) public hasVoted;

    event PatentSubmitted(uint id, string title, address applicant);
    event Voted(uint patentId, address examiner, bool support);
    event PatentApproved(uint id, string title);

    constructor() {
        admin = msg.sender;
    }

    function addExaminer(address _examiner) public {
        require(msg.sender == admin, "Only admin");
        isExaminer[_examiner] = true;
    }

    function submitPatent(string memory _title) public returns (uint) {
        proposalCount++;
        patents[proposalCount] = Patent(
            proposalCount, _title, msg.sender, 0, 0, false, true
        );
        emit PatentSubmitted(proposalCount, _title, msg.sender);
        return proposalCount;
    }

    function vote(uint _patentId, bool _support) public {
        require(isExaminer[msg.sender], "Not an examiner");
        require(patents[_patentId].exists, "Patent not found");
        require(!hasVoted[_patentId][msg.sender], "Already voted");

        hasVoted[_patentId][msg.sender] = true;

        if (_support) {
            patents[_patentId].votesFor++;
        } else {
            patents[_patentId].votesAgainst++;
        }

        emit Voted(_patentId, msg.sender, _support);
    }

    function approvePatent(uint _patentId) public {
        require(msg.sender == admin, "Only admin");
        Patent storage p = patents[_patentId];
        require(p.exists, "Patent not found");
        require(p.votesFor > p.votesAgainst, "Insufficient votes");

        p.approved = true;
        emit PatentApproved(_patentId, p.title);
    }

    function getPatent(uint _patentId) public view returns (
        string memory title, address applicant, 
        uint votesFor, uint votesAgainst, bool approved
    ) {
        Patent storage p = patents[_patentId];
        return (p.title, p.applicant, p.votesFor, p.votesAgainst, p.approved);
    }
}

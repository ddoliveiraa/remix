// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Member.sol"; // Importing the Member contract

contract Team {
    string public name;
    address[] public members;  // Store team members as addresses

    // Constructor for the team
    constructor(string memory _name, address[] memory _members) {
        name = _name;
        for (uint256 i = 0; i < _members.length; i++) {
            members.push(_members[i]);
        }
    }

    function addMember(address _memberAddress) public {
        members.push(_memberAddress);
    }

    function listMembers() public view returns (address[] memory) {
        return members;
    }
}

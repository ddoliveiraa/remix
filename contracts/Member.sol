// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Member {
    string public name;
    string[] public skills;

    // Constructor for the member
    constructor(string memory _name) {
        name = _name;
    }

    // Function to add a skill to the member
    function addSkill(string memory _skill) public {
        skills.push(_skill);
    }

    // Function to list the skills of the member
    function listSkills() public view returns (string[] memory) {
        return skills;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Member.sol";

contract Hackathon {
    string public title;
    string public theme;
    address public organizer;
    address[] public participants;

    // Mapping to store members by address
    mapping(address => bool) public isMember;

    // Constructor for Hackathon
    constructor(string memory _title, string memory _theme, address _organizer) {
        title = _title;
        theme = _theme;
        organizer = _organizer;
    }

    // Register a participant (must be a valid member)
    function registerParticipant(address _memberAddress) public {
        require(isMember[_memberAddress], "Not a valid member");
        participants.push(_memberAddress);
    }

    // List participants of the hackathon
    function listParticipants() public view returns (address[] memory) {
        return participants;
    }

    // Add a member to the member registry (only the organizer can add members)
    function addMember(address _memberAddress) public {
        require(msg.sender == organizer, "Only organizer can add members");
        isMember[_memberAddress] = true;
    }
}

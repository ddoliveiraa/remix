// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Team.sol";

contract Hackathon {
    string public title;
    string public theme;
    address public organizer;
    Team[] public teams;
    
    mapping(address => bool) public participants; // List of registered participants
    mapping(address => address) public participantTeam; // Which team a participant belongs to
    address[] private participantList; // Stores participant addresses

    event ParticipantRegistered(address indexed participant);
    event TeamCreated(address indexed teamAddress, string teamName);

    constructor(string memory _title, string memory _theme, address _organizer) {
        title = _title;
        theme = _theme;
        organizer = _organizer;
    }

    // Function to register as a participant
    function registerParticipant(address _participant) public {
        require(!participants[_participant], "Already registered");
        participants[_participant] = true;
        participantList.push(_participant); // Store the participant's address

        emit ParticipantRegistered(_participant);
    }

    // Function to create and add a new team
    function addTeam(address _creator, string memory _name) public returns (address) {
        require(_creator == organizer || participants[_creator], "Only participants or organizer can create teams");
        require(participantTeam[_creator] == address(0), "Already in a team");

        Team newTeam = new Team(_name);
        teams.push(newTeam);
        
        // Assign the creator to the new team
        participantTeam[_creator] = address(newTeam);

        emit TeamCreated(address(newTeam), _name);
        return address(newTeam);
    }

    // Function to list all teams in this hackathon
    function listTeams() public view returns (address[] memory) {
        address[] memory teamAddresses = new address[](teams.length);
        for (uint i = 0; i < teams.length; i++) {
            teamAddresses[i] = address(teams[i]);
        }
        return teamAddresses;
    }

    // ✅ Function to list all participants
    function listParticipants() public view returns (address[] memory) {
        return participantList;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Hackathon.sol";

contract Manager {
    struct HackathonDetails {
        address contractAddress;
        string title;
        string theme;
        address[] participants;
        address[] teams;
    }

    Hackathon[] private hackathons;
    mapping(address => HackathonDetails) private hackathonInfo;
    mapping(address => string[]) private participantSkills;

    event HackathonCreated(address indexed hackathonAddress, string title, string theme);
    event TeamAdded(address indexed hackathonAddress, address teamAddress, string teamName);
    event ParticipantRegistered(address indexed hackathonAddress, address participant);

    function createHackathon(string memory _title, string memory _theme) public {
        Hackathon newHackathon = new Hackathon(_title, _theme, msg.sender);
        
        hackathons.push(newHackathon);
        
        hackathonInfo[address(newHackathon)] = HackathonDetails({
            contractAddress: address(newHackathon),
            title: _title,
            theme: _theme,
            participants: new address[](0),
            teams: new address[](0)
        });

        emit HackathonCreated(address(newHackathon), _title, _theme);
    }

    function listHackathons() public view returns (HackathonDetails[] memory) {
        HackathonDetails[] memory hackathonList = new HackathonDetails[](hackathons.length);

        for (uint i = 0; i < hackathons.length; i++) {
            address hackathonAddress = address(hackathons[i]);
            Hackathon hackathon = Hackathon(hackathonAddress);

            hackathonList[i] = HackathonDetails({
                contractAddress: hackathonAddress,
                title: hackathon.title(),
                theme: hackathon.theme(),
                participants: hackathon.listParticipants(),
                teams: hackathon.listTeams()
            });
        }

        return hackathonList;
    }

    function addParticipantToHackathon(address _hackathonAddress) public {
        Hackathon hackathon = Hackathon(_hackathonAddress);
        
        hackathon.registerParticipant(msg.sender);

        hackathonInfo[_hackathonAddress].participants.push(msg.sender);

        emit ParticipantRegistered(_hackathonAddress, msg.sender);
    }

    function getHackathonInfo(address _hackathonAddress) public view returns (
        address contractAddress, 
        string memory title, 
        string memory theme, 
        address[] memory participants, 
        address[] memory teams
    ) {
        Hackathon hackathon = Hackathon(_hackathonAddress);

        return (
            _hackathonAddress,
            hackathon.title(),
            hackathon.theme(),
            hackathon.listParticipants(),
            hackathon.listTeams()
        );
    }

    function addSkillsToParticipant(string[] memory _skills) public {
        for (uint256 i = 0; i < _skills.length; i++) {
            participantSkills[msg.sender].push(_skills[i]);
        }
    }

    function getParticipantInfo(address _participant) public view returns (address participantAddress, string[] memory skills) {
        return (
            _participant,
            participantSkills[_participant]
        );
    }
}

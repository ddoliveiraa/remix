// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Hackathon.sol";
import "./Member.sol";
import "./Team.sol";

contract Manager {
    struct HackathonDetails {
        address contractAddress;
        string title;
        string theme;
        address[] participants;
        address[] teams;
    }

    struct MemberDetails {
        address memberAddress;
        string name;
        string[] skills;
    }

    // Array to store all hackathons
    Hackathon[] private hackathons;
    
    // Mapping to store hackathon details by address
    mapping(address => HackathonDetails) private hackathonInfo;

    // Mapping to track if a member has been created
    mapping(address => bool) private memberExists;

    // Mapping to store member contract addresses
    mapping(address => address) private memberContracts;

    // Array to store all members
    address[] private allMembers;

    event HackathonCreated(address indexed hackathonAddress, string title, string theme);
    event ParticipantRegistered(address indexed hackathonAddress, address participant);
    event MemberCreated(address indexed memberAddress, string name);
    event TeamCreated(address indexed hackathonAddress, address teamAddress, string teamName);

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

    function createMember(string memory _name) public {
        require(!memberExists[msg.sender], "You already have a member account.");

        Member newMember = new Member(_name);
        memberExists[msg.sender] = true;
        memberContracts[msg.sender] = address(newMember);
        allMembers.push(msg.sender);

        emit MemberCreated(address(newMember), _name);
    }

    function addSkillToMe(string memory _skill) public {
        require(memberExists[msg.sender], "You do not have a member account.");

        Member member = Member(memberContracts[msg.sender]);
        member.addSkill(_skill);
    }

    function addParticipantToHackathon(address _hackathonAddress) public 
    {
        require(memberExists[msg.sender], "You are not a registered member!"); // Check if member exists
        
        Hackathon hackathon = Hackathon(_hackathonAddress);
        
        // Ensure the sender is registered as a member in the hackathon
        if (!hackathon.isMember(msg.sender)) {
            hackathon.addMember(msg.sender); // Add them if they are not in the hackathon yet
        }

        hackathon.registerParticipant(msg.sender);
        hackathonInfo[_hackathonAddress].participants.push(msg.sender);

        emit ParticipantRegistered(_hackathonAddress, msg.sender);
    }


    function createTeam(address _hackathonAddress, string memory _teamName, address[] memory _members) public {
        Hackathon hackathon = Hackathon(_hackathonAddress);

        bool isParticipant = false;
        address[] memory participants = hackathon.listParticipants();
        for (uint256 i = 0; i < participants.length; i++) {
            if (participants[i] == msg.sender) {
                isParticipant = true;
                break;
            }
        }
        require(isParticipant || msg.sender == hackathon.organizer(), "Only participants or the organizer can create a team.");

        Team newTeam = new Team(_teamName, _members);
        hackathonInfo[_hackathonAddress].teams.push(address(newTeam));

        emit TeamCreated(_hackathonAddress, address(newTeam), _teamName);
    }

    function listHackathons() public view returns (HackathonDetails[] memory) {
        HackathonDetails[] memory hackathonList = new HackathonDetails[](hackathons.length);
        for (uint256 i = 0; i < hackathons.length; i++) {
            address hackathonAddress = address(hackathons[i]);
            Hackathon hackathon = Hackathon(hackathonAddress);
            hackathonList[i] = HackathonDetails({
                contractAddress: hackathonAddress,
                title: hackathon.title(),
                theme: hackathon.theme(),
                participants: hackathon.listParticipants(),
                teams: hackathonInfo[hackathonAddress].teams
            });
        }
        return hackathonList;
    }

    function getHackathonInfo(address _hackathonAddress) public view returns (
        string memory title,
        string memory theme,
        address[] memory participants,
        address[] memory teams
    ) {
        HackathonDetails storage hackathon = hackathonInfo[_hackathonAddress];
        title = hackathon.title;
        theme = hackathon.theme;
        participants = hackathon.participants;
        teams = hackathon.teams;
        return (title, theme, participants, teams);
    }

    function getMembers() public view returns (MemberDetails[] memory) {
        MemberDetails[] memory membersList = new MemberDetails[](allMembers.length);
        for (uint256 i = 0; i < allMembers.length; i++) {
            address memberAddr = allMembers[i];
            Member member = Member(memberContracts[memberAddr]);

            membersList[i] = MemberDetails({
                memberAddress: memberAddr,
                name: member.name(),
                skills: member.listSkills()
            });
        }
        return membersList;
    }


}

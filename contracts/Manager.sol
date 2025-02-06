// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

import "./Hackathon.sol";
import "./Member.sol";
import "./Team.sol";

contract Manager is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(
        bytes32 indexed requestId,
        string character,
        bytes response,
        bytes err
    );

    address router = 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28;
    uint32 gasLimit = 300000;
    bytes32 donID = 0x66756e2d6f7074696d69736d2d7365706f6c69612d3100000000000000000000;
    
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    struct HackathonDetails {
        address contractAddress;
        string title;
        string theme;
        address[] participants;
        address[] teams;
    }

    struct MemberDetails {
        uint256 id;
        address memberAddress;
        string name;
        string[] skills;
    }

    struct TeamData {
        string name;
        address[] participants;
    }

    // Array to store all hackathons
    Hackathon[] private hackathons;

    address[] private allMembers;

    uint256 private nextMemberID;
    
    // Mapping to store hackathon details by address
    mapping(address => HackathonDetails) private hackathonInfo;

    // Mapping to track if a member has been created
    mapping(address => bool) private memberExists;

    // Mapping to store member contract addresses
    mapping(address => address) private memberContracts;

    mapping(address => uint256) private memberIDs;

    mapping(address => string[]) private memberSkills; // Mapping to store member skills

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

        // Assign the next available member ID
        uint256 memberID = nextMemberID++;
        
        Member newMember = new Member(_name);
        memberExists[msg.sender] = true;
        memberContracts[msg.sender] = address(newMember);
        memberIDs[msg.sender] = memberID;  // Store the ID for the member
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

    /* function listHackathons() public view returns (HackathonDetails[] memory) {
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
    } */

/*     function getHackathonInfo(address _hackathonAddress) public view returns (
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
    } */

    function getMembers() public view returns (MemberDetails[] memory) {
        MemberDetails[] memory membersList = new MemberDetails[](allMembers.length);
        for (uint256 i = 0; i < allMembers.length; i++) {
            address memberAddr = allMembers[i];
            Member member = Member(memberContracts[memberAddr]);

            membersList[i] = MemberDetails({
                id: memberIDs[memberAddr],  // Include member ID
                memberAddress: memberAddr,
                name: member.name(),
                skills: member.listSkills()
            });
        }
        return membersList;
    }

    // Function to send the request to Chainlink Functions
    function sendRequest(
        uint64 subscriptionId,
        string[] memory participantData
    ) public onlyOwner returns (bytes32 requestId) {
        string memory source = 
            "const apiResponse = await Functions.makeHttpRequest({"
            "url: `https://eight-games-talk.loca.lt/`"
            "});"
            "if (apiResponse.error) {"
            "throw Error('Request failed');"
            "}"
            "const { data } = apiResponse;"
            "return Functions.encodeString(data.teamName);";

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        // Pass the structured participant data to the external API
        req.setArgs(participantData);

        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    // Function to allocate participants to teams using external API
    function allocateParticipantsToTeams(address _hackathonAddress) external onlyOwner {
        Hackathon hackathon = Hackathon(_hackathonAddress);
        address[] memory participants = hackathon.listParticipants();

        // Collect participant data (ID and skills) in structured format
        string[] memory participantData = new string[](participants.length);
        for (uint256 i = 0; i < participants.length; i++) {
            uint256 memberId = memberIDs[participants[i]];
            string memory skills = getMemberSkills(participants[i]);

            // Create the structured object: {id: memberId, skills: [skills]}
            string memory participantObject = string(abi.encodePacked(
                "{id: ", memberId, ", skills: [", skills, "]}"
            ));

            participantData[i] = participantObject;
        }

        // Send this structured data to the external API
        sendRequest(423, participantData); // Call the sendRequest function to send the request data
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }

        s_lastResponse = response;
        s_lastError = err;

        emit Response(requestId, "Team Data", s_lastResponse, s_lastError);

        // Decode the response properly
        TeamData[] memory teams = abi.decode(response, (TeamData[]));

        // Create teams from the response
        createTeamsFromResponse(teams);
    }

    // Function to create teams based on the response from Chainlink API
    function createTeamsFromResponse(TeamData[] memory teams) internal {
        for (uint256 i = 0; i < teams.length; i++) {
            createTeam(teams[i].name, teams[i].participants);
        }
    }

    // Utility function to convert uint to string
/*     function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
 */
    function parseResponse(string memory response) internal pure returns (string memory) {
        return response;
    }

    // Helper function to create teams from parsed data
    function createTeam(string memory _teamName, address[] memory _members) internal {
    }

    function getMemberSkills(address _memberAddress) internal view returns (string memory) {
        string[] memory skills = memberSkills[_memberAddress];
        // Convert skills array into a string (you may need to adjust how this is done)
        string memory skillsString = "";
        for (uint256 i = 0; i < skills.length; i++) {
            skillsString = string(abi.encodePacked(skillsString, skills[i], ","));
        }
        return skillsString;
    }
}

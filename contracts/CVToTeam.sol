// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract CVToTeam is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    struct Person {
        uint256 id;
        string name;
        string[] skills;
    }

    struct Team {
        string name;
        uint256[] members;
    }

    mapping(uint256 => Person) private people;
    uint256[] private personIds;
    mapping(string => Team) private teams;
    string[] private teamNames;
    Team[] private teamsFinal;

    event PersonAdded(uint256 id, string name);
    event SkillsUpdated(uint256 id, string[] skills);
    event TeamCreated(string name, uint256[] members);
    event Response(
        bytes32 indexed requestId, 
        string teamsWithMembers, 
        bytes response, 
        bytes err
    );
    // string private teamsWithMembers;
    event TeamsGenerated(Team[] teams);

    string public teamsWithMembers;

    bytes32 private s_lastRequestId;
    bytes private s_lastResponse;
    bytes private s_lastError;

    address router = 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28;
    uint32 gasLimit = 300_000;
    bytes32 donID = 0x66756e2d6f7074696d69736d2d7365706f6c69612d3100000000000000000000;

    error UnexpectedRequestID(bytes32 requestId);


    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    function addPerson(uint256 _id, string memory _name, string[] memory _skills) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(people[_id].id == 0, "Person with this ID already exists");

        people[_id] = Person({id: _id, name: _name, skills: _skills});
        personIds.push(_id);

        emit PersonAdded(_id, _name);
    }

    function getPerson(uint256 _id) public view returns (string memory, string[] memory) {
        require(people[_id].id != 0, "Person does not exist");
        Person storage person = people[_id];
        return (person.name, person.skills);
    }

    function updateSkills(uint256 _id, string[] memory _skills) public {
        require(people[_id].id != 0, "Person does not exist");
        people[_id].skills = _skills;
        emit SkillsUpdated(_id, _skills);
    }

    function getAllPeople() public view returns (Person[] memory) {
        Person[] memory personList = new Person[](personIds.length);
        for (uint256 i = 0; i < personIds.length; i++) {
            personList[i] = people[personIds[i]];
        }
        return personList;
    }

    function createTeam(string memory _name, uint256[] memory _members) public {
        require(bytes(_name).length > 0, "Team name cannot be empty");
        require(teams[_name].members.length == 0, "Team already exists");

        teams[_name] = Team({name: _name, members: _members});
        teamNames.push(_name);

        emit TeamCreated(_name, _members);
    }

    function getTeam(string memory _name) public view returns (string memory, Person[] memory) {
        require(teams[_name].members.length > 0, "Team does not exist");
        Team storage team = teams[_name];
        
        Person[] memory teamMembers = new Person[](team.members.length);
        for (uint256 i = 0; i < team.members.length; i++) {
            teamMembers[i] = people[team.members[i]];
        }
        
        return (team.name, teamMembers);
    }

    string source =
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://rndhn-148-69-167-195.a.free.pinggy.link/generate-team`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data);";

    function sendRequest(
        uint64 subscriptionId
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

     function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        teamsWithMembers = string(response);
        s_lastError = err;

        // Emit an event to log the response
        emit Response(requestId, teamsWithMembers, s_lastResponse, s_lastError);
    }

    function getAllTeams() public view returns (Team[] memory) {
        Team[] memory allTeams = new Team[](teamNames.length);
        for (uint256 i = 0; i < teamNames.length; i++) {
            allTeams[i] = teams[teamNames[i]];
        }
        return allTeams;
    }

/*     function generateTeams() public {
        Team[] memory parsedTeams = parseTeamsFromString(teamsWithMembers);

        // Clear the storage array first
        delete teamsFinal;

        // Manually copy each team from memory to storage
        for (uint256 i = 0; i < parsedTeams.length; i++) {
            teamsFinal.push(parsedTeams[i]);
        }

        emit TeamsGenerated(teamsFinal);
    }


    function getAllTeams() public view returns (Team[] memory) {
        return teamsFinal;
    }

    // Helper function to convert a string of teams into an array of Team structs
    function parseTeamsFromString(string memory teamsJson) public pure returns (Team[] memory) {
        uint256 teamsCount = countOccurrences(teamsJson, "{\"name\":\"");
        Team[] memory teamsList = new Team[](teamsCount);

        uint256 teamIndex = 0;
        uint256 offset = 0;

        while (offset < bytes(teamsJson).length) {
            // Find the start of the next team name
            uint256 nameStart = indexOf(teamsJson, "\"name\":\"", offset);
            uint256 nameEnd = indexOf(teamsJson, '"', nameStart + 7);
            string memory teamName = substring(teamsJson, nameStart + 8, nameEnd);

            // Find the members array
            uint256 membersStart = indexOf(teamsJson, '"members":', nameEnd);
            uint256 membersEnd = indexOf(teamsJson, ']', membersStart + 11);
            string memory membersStr = substring(teamsJson, membersStart + 10, membersEnd);

            // Convert the members string to an array of uint256
            uint256[] memory members = parseMembers(membersStr);

            teamsList[teamIndex] = Team({
                name: teamName,
                members: members
            });

            teamIndex++;
            offset = membersEnd + 1;
        }

        return teamsList;
    }

    // Helper function to count occurrences of a substring in a string
    function countOccurrences(string memory str, string memory search) private pure returns (uint256) {
        uint256 count = 0;
        uint256 offset = 0;
        while (true) {
            offset = indexOf(str, search, offset);
            if (offset == type(uint256).max) {
                break;
            }
            count++;
            offset++;
        }
        return count;
    }

    // Helper function to find the index of a substring
    function indexOf(string memory str, string memory search, uint256 start) private pure returns (uint256) {
        bytes memory strBytes = bytes(str);
        bytes memory searchBytes = bytes(search);
        
        if (searchBytes.length == 0 || strBytes.length == 0 || searchBytes.length > strBytes.length) {
            return type(uint256).max;  // Return the maximum uint256 value to indicate "not found"
        }

        for (uint256 i = start; i <= strBytes.length - searchBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < searchBytes.length; j++) {
                if (strBytes[i + j] != searchBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return i;
            }
        }

        return type(uint256).max;  // Return the maximum uint256 value if not found
    }

    // Helper function to extract a substring from a string
    function substring(string memory str, uint256 start, uint256 end) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(end - start);
        for (uint256 i = start; i < end; i++) {
            result[i - start] = strBytes[i];
        }
        return string(result);
    }

    // Helper function to parse the members string into an array of uint256
    function parseMembers(string memory membersStr) private pure returns (uint256[] memory) {
        uint256 membersCount = countOccurrences(membersStr, ',') + 1;
        uint256[] memory members = new uint256[](membersCount);

        uint256 offset = 0;
        for (uint256 i = 0; i < membersCount; i++) {
            uint256 nextComma = indexOf(membersStr, ',', offset);
            if (nextComma == type(uint256).max) {
                nextComma = bytes(membersStr).length;
            }

            string memory memberStr = substring(membersStr, offset, nextComma);
            members[i] = stringToUint(memberStr);

            offset = nextComma + 1;
        }

        return members;
    }

    // Helper function to convert a string to uint256
    function stringToUint(string memory str) private pure returns (uint256) {
        bytes memory strBytes = bytes(str);
        uint256 result = 0;

        for (uint256 i = 0; i < strBytes.length; i++) {
            result = result * 10 + (uint256(uint8(strBytes[i])) - 48);
        }

        return result;
    } */
    
}

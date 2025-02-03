// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract CVToTeam is FunctionsClient, ConfirmedOwner 
{
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
    string public character;

    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    string source =
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://eight-games-talk.loca.lt/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.teamName);";


    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) 
    {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        if (args.length > 0) req.setArgs(args);

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
    ) internal override 
    {
        if (s_lastRequestId != requestId) 
        {
            revert UnexpectedRequestID(requestId);
        }

        s_lastResponse = response;
        character = string(response);
        s_lastError = err;

        emit Response(requestId, character, s_lastResponse, s_lastError);
    }
}
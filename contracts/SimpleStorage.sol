// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract SimpleStorage 
{
    struct Person {
        uint256 favoriteNumber;
        string name;
    }
    

    uint256 internal  myFavoriteNumber;

    uint256[] listOfFavoriteNumber;


    function store(uint256 _favoriteNumber) public 
    {
        myFavoriteNumber = _favoriteNumber;
    }

    function getFavoriteNumber() public view returns (uint256)
    {
        return myFavoriteNumber;
    }
}
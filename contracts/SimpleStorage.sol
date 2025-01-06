// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract SimpleStorage 
{
    uint256 internal  favoriteNumber;

    function store(uint256 _favoriteNumber) public 
    {
        favoriteNumber = _favoriteNumber;
    }

    function getFavoriteNumber() public view returns (uint256)
    {
        return favoriteNumber * favoriteNumber;
    }
}
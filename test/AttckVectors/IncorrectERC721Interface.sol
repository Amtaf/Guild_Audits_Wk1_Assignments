// SPDX-License-Identifier: UNLICENSED
/*
Name: Incorrect erc721 interface

Incorrect return values for ERC721 functions.
A contract compiled with solidity > 0.4.22 interacting with these functions will fail to execute them, as the return value is missing

Token.ownerOf does not return an address like ERC721 expects. 
Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct ERC721 interface implementation. Alice's contract is unable to interact with Bob's contract.
*/

contract Token{
    function ownerOf(uint256 _tokenId) external view returns (bool);
    //...
}
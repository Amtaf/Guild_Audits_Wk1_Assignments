// SPDX-License-Identifier: UNLICENSED
/*
Name: Incorrect erc20 interface

Incorrect return values for ERC20 functions. A contract compiled with Solidity > 0.4.22
interacting with these functions will fail to execute them, as the return value is missing.

For instance the contract below: Token.transfer does not return a boolean.
Bob deploys the token. Alice creates a contract that interacts with it but assumes a correct ERC20 interface implementation. 
Alice's contract is unable to interact with Bob's contract.
*/

contract Token{
    function transfer(address to, uint value) external;
    //...
}
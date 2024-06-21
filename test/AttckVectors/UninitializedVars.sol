// SPDX-License-Identifier: AGPL-3.0-only
/*
Name: Uninitialized state variables.

Uninitialized state variables are assigned zero by compilers causing unintended results.

mitigation: Initialize all variables(local/state)

For instance this contract Bob calls transfer. As a result, the Ether are sent to the address 0x0 and are lost.
*/
pragma solidity 0.8.20;
contract Uninitialized{
    address destination;

    function transfer() payable public{
        destination.transfer(msg.value);
    }
}
// SPDX-License-Identifier: UNLICENSED
/*
Name: Underflow
An underflow vulnerability in Solidity occurs when an arithmetic operation results in a value that is lower than the minimum limit of the data type being used,
causing the calculation to wrap around and start from the next largest possible value. 
This can lead to unexpected behavior and potential exploits in smart contracts.

*/
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
contract Underflow {
    uint8 public count;

    // uint8 has a min value of 0, but if we subtract 1 from 0, we get 255 if it's unchecked!
    // Versions prior to 0.8 of solidity also have this issue
    function decrement() public {
        unchecked {
            count--;
        }
    }
}

contract testsUnderflow is Test{
    Underflow underflow;

    function setUp() public {
        underflow = new Underflow();
    }
    function testUnderflow() public {
        //calling the underflow::decrement function
        underflow.decrement();
        uint8 expectedNumber = 255;
        assertEq(underflow.count(), expectedNumber, "Didnt underflow");
    }
}

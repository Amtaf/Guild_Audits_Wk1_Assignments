// SPDX-License-Identifier: UNLICENSED

/*
Name: Overflow

An overflow vulnerability occurs when an arithmetic operation 
attempts to create a numeric value that is higher than the maximum limit of the data type 
being used. This can lead to unexpected behavior.
*/
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract OverflowToken {
    mapping(address => uint256) public balances;

    constructor(){
        balances[msg.sender] = 2**256 - 1;  // Initialize the deployer with the maximum uint256 value
    }

    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}



contract TestOverflow is Test {
    OverflowToken token;

    function setUp() public {
        token = new OverflowToken();
    }

    function testOverflow() public {
        address recipient = address(0x123);
        uint256 initialBalance = token.balances(address(this));
        
        // Expect the transfer to overflow
        vm.expectRevert();
        token.transfer(recipient, initialBalance + 1);
        
        // Transfer a large amount to cause an overflow
        token.transfer(recipient, initialBalance);
        
        uint256 newBalance = token.balances(address(this));
        
        // Check if the balance wrapped around
        assertEq(newBalance, 0);
    }
}

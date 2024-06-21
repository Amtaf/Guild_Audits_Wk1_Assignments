// SPDX-License-Identifier: AGPL-3.0-only

/*
Some tokens have more than 18 decimals (e.g. YAM-V2 has 24).

This may trigger unexpected reverts due to overflow, posing a liveness risk to the contract.
*/

pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";

contract HighDecimalToken is ERC20 {
    constructor(uint _totalSupply) ERC20(_totalSupply) public {
        decimals = 50;
    }

     
}

contract TestHighDecimalToken is Test{
    HighDecimalToken highDecimalTkn;
    function setUp() public{
        highDecimalTkn = new HighDecimalToken(1e50);

    }

    function testTransferOverflow() public{
        uint256 totalSupply = highDecimalTkn.totalSupply();
        assertEq(totalSupply,1e50);

        address recipient = address(0x123);
        uint256 amount = 1e50/2; 

        bool success = highDecimalTkn.transfer(recipient, amount);
        assertTrue(success);

        uint256 senderBalance = highDecimalTkn.balanceOf(address(this));
        uint256 recipientBalance = highDecimalTkn.balanceOf(recipient);

        assertEq(senderBalance,totalSupply-amount);
        assertEq(recipientBalance, amount);


    }

    function testHighDecimalApprove() public {
        
    }
}
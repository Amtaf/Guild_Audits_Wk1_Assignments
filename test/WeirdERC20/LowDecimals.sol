// SPDX-License-Identifier: AGPL-3.0-only
/*Low Decimals
Some tokens have low decimals (e.g. USDC has 6). Even more extreme,
some tokens like Gemini USD only have 2 decimals.

This may result in larger than expected precision loss.

*/


pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";

contract LowDecimalToken is ERC20 {
    constructor(uint _totalSupply) ERC20(_totalSupply) public {
        decimals = 6;
    }
}

contract TestLowDecimalToken is Test{
    LowDecimalToken lowDecimalTkn;
    function setUp() public{
        lowDecimalTkn = new LowDecimalToken(1e6);

    }

    function testLowDecimalPrecisionLoss() public{
        uint256 totalSupply = lowDecimalTkn.totalSupply();
        assertEq(totalSupply,1e6);

        address recipient = address(0x123);
        uint256 amount = 1e6/2; 

        bool success = lowDecimalTkn.transfer(recipient, amount);
        assertTrue(success);

        uint256 senderBalance = lowDecimalTkn.balanceOf(address(this));
        uint256 recipientBalance = lowDecimalTkn.balanceOf(recipient);

        assertEq(senderBalance,totalSupply-amount);
        assertEq(recipientBalance, amount);


    }

    
}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// Import the SafeCast library
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

/*
Name: Unsafe downcasting


Description: Downcasting from a larger integer type to a smaller one without checks can lead to unexpected behavior 
if the value of the larger integer is outside the range of the smaller one.

*/


contract SimpleBank {
    mapping(address => uint) private balances;

    function deposit(uint256 amount) public {
        // Here's the unsafe downcast. If the `amount` is greater than type(uint8).max
        // (which is 255), then only the least significant 8 bits are stored in balance.
        // This could lead to unexpected results due to overflow.
        uint8 balance = uint8(amount);

        // store the balance
        balances[msg.sender] = balance;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}

contract ContractTest is Test {
    SimpleBank SimpleBankContract;
    

    function setUp() public {
        SimpleBankContract = new SimpleBank();
        
    }

    function testUnsafeDowncast() public {
        SimpleBankContract.deposit(257); //overflowed

        console.log(
            "balance of SimpleBankContract:",
            SimpleBankContract.getBalance()
        );

        // balance is 1, because of overflowed
        assertEq(SimpleBankContract.getBalance(), 1);
    }

    receive() external payable {}
}


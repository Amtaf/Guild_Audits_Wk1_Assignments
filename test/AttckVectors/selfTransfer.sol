// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/*
Name: Missing Check for Self-Transfer Allows Funds to be Lost

Description:
The vulnerability in the code stems from the absence of a check to prevent self-transfers. 
This oversight allows the transfer function to erroneously transfer funds to the same address. 
Consequently, funds are lost as the code fails to deduct the transferred amount from the sender's balance.
This vulnerability undermines the correctness of fund transfers within the contract and poses a risk 
to the integrity of user balances.
 
Mitigation:  
Add condition to prevent transfer between same addresses


*/


contract SimpleBank {
    mapping(address => uint256) private _balances;

    function balanceOf(address _account) public view virtual returns (uint256) {
        return _balances[_account];
    }

    function transfer(address _from, address _to, uint256 _amount) public {
        // not check self-transfer
        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract ContractTest is Test {
    SimpleBank VSimpleBankContract;


    function setUp() public {
        VSimpleBankContract = new SimpleBank();
        
    }

    function testSelfTransfer() public {
        VSimpleBankContract.transfer(address(this), address(this), 10000);
        VSimpleBankContract.transfer(address(this), address(this), 10000);
        VSimpleBankContract.balanceOf(address(this));
        /*
        unchecked {
        _balances[_id][Alice] = 10000 - 10000;
        _balances[_id][Alice] = 10000 + 10000;
         total balance of [Alice] = 20000
        }
        */
    }

    
    receive() external payable {}
}

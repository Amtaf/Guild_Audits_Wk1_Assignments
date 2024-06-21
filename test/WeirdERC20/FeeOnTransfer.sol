// SPDX-License-Identifier: MIT
/*
Name: Fee on Transfer tokens/Rebase
Odd Behavior: tokens that change balance on transfer
*/
pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";

contract TransferFeeToken is ERC20 {

    uint immutable fee;

    constructor(uint _totalSupply, uint _fee) ERC20(_totalSupply) public {
        fee = _fee;
    }

    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(balanceOf[src] >= wad, "insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= wad, "insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }

        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], sub(wad, fee));
        balanceOf[address(0)] = add(balanceOf[address(0)], fee);

        emit Transfer(src, dst, sub(wad, fee));
        emit Transfer(src, address(0), fee);

        return true;
    }
}

contract TransferFeeTokenTest is Test {
    TransferFeeToken token;
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new TransferFeeToken(1000 ether, 1 ether);
        token.transfer(user1, 500 ether);
        token.transfer(user2, 500 ether);
    }

    function testTransferWithFee() public {
        vm.startPrank(user1);
        token.approve(address(this), 100 ether);
        bool success = token.transferFrom(user1, user2, 100 ether);
        vm.stopPrank();

        assertTrue(success);
        assertEq(token.balanceOf(user1), 399 ether);
        assertEq(token.balanceOf(user2), 598 ether);
        assertEq(token.balanceOf(address(0)), 3 ether);
    }
}



// Copyright (C) 2020 d-xo
// SPDX-License-Identifier: AGPL-3.0-only

//Some tokens (e.g. LEND) revert when transferring a zero value amount.

pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";


contract RevertZeroToken is ERC20 {
    // --- Init ---
    constructor(uint _totalSupply) ERC20(_totalSupply) public {}

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(wad != 0, "zero-value-transfer");
        return super.transferFrom(src, dst, wad);
    }
}

contract RevertZeroTokenTest is Test {
    RevertZeroToken token;
    address alice;
    address bob;

    function setUp() public {
        alice = address(0x123);
        bob = address(0x456);
        token = new RevertZeroToken(1000);

        token.transfer(alice, 500);
        token.approve(address(this), 500);
    }

    function testTransferFrom() public {
        // Regular transfer
        token.transferFrom(alice, bob, 100);
        assertEq(token.balanceOf(bob), 100);

        // Zero-value transfer
        vm.expectRevert(bytes("zero-value-transfer"));
        token.transferFrom(alice, bob, 0);
    }

    function testTransferFromZeroValue() public {
        vm.expectRevert(bytes("zero-value-transfer"));
        token.transferFrom(alice, bob, 0);
    }
}
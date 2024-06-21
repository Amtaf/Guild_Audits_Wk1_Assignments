// SPDX-License-Identifier: AGPL-3.0-only
/*
Some tokens (e.g. openzeppelin) revert when attempting to transfer to address(0).

This may break systems that expect to be able to burn tokens by transferring them to address(0)
*/

pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";


contract RevertToZeroToken is ERC20 {
    // --- Init ---
    constructor(uint _totalSupply) ERC20(_totalSupply) public {}

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(dst != address(0), "transfer-to-zero");
        return super.transferFrom(src, dst, wad);
    }
}



contract RevertToZeroTokenTest is Test {
    RevertToZeroToken token;
    address user = address(0x123);

    function setUp() public {
        token = new RevertToZeroToken(1000);
        token.approve(user, 500);
    }

    function testTransferToZeroAddressShouldRevert() public {
        vm.expectRevert("transfer-to-zero");
        token.transfer(address(0), 100);
    }

    function testTransferFromToZeroAddressShouldRevert() public {
        vm.expectRevert("transfer-to-zero");
        token.transferFrom(address(this), address(0), 100);
    }

    function testTransferToValidAddress() public {
        token.transfer(user, 100);
        assertEq(token.balanceOf(user), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }

    function testTransferFromValidAddress() public {
        token.transferFrom(address(this), user, 100);
        assertEq(token.balanceOf(user), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }
}

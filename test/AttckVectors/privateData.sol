// SPDX-License-Identifier: MIT

/*

Storing passwords or private data on-chain is generally considered insecure due to 
the inherent transparency and immutability of blockchain technology. 
*/
pragma solidity ^0.8.18;


import "forge-std/Test.sol";

contract PasswordStore {
    address private s_owner;
    string private s_password;

    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    function getPassword() external view returns (string memory) {
        if (msg.sender!= s_owner) {
            revert("Only the owner can retrieve the password.");
        }
        return s_password;
    }
}

contract AttackContract {
    PasswordStore public targetContract;

    constructor(address targetAddress) {
        targetContract = PasswordStore(targetAddress);
    }

    function attemptToGetPassword() public view returns (string memory) {
        return targetContract.getPassword();
    }
}

contract PasswordAttackTest is Test {
    PasswordStore public passwordStore;
    AttackContract public attackContract;

    function setUp() public {
        passwordStore = new PasswordStore();
        attackContract = new AttackContract(address(passwordStore));
    }

    function testPasswordAttack() public {
        // Set a password in the PasswordStore contract
        passwordStore.setPassword("secret");

        // Try to retrieve the password using the attack contract
        // This should fail since the attack contract is not the owner
        vm.expectRevert("Only the owner can retrieve the password.");
        attackContract.attemptToGetPassword();
    }
}
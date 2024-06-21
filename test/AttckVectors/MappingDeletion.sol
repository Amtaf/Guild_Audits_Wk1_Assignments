/*
Name: Deletion on mapping containing a structure

A deletion in a structure containing a mapping will not delete the mapping. 
The remaining data may be used to compromise the contract.

remove deletes an item of stackBalance. The mapping balances is never deleted, so remove does not work as intended.

Recommendation
Use a lock mechanism instead of a deletion to disable structure containing a mapping.
*/

    struct BalancesStruct{
        address owner;
        mapping(address => uint) balances;
    }
    mapping(address => BalancesStruct) public stackBalance;

    function remove() internal{
         delete stackBalance[msg.sender];
    }
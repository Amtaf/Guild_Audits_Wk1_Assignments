/*
Name: 
Dynamic type usages in abi.encodePacked causes collision

The contract example below: Bob calls get_hash_for_signature with (bob, This is the content).
The hash returned is used as an ID. Eve creates a collision with the ID using (bo, bThis is the content) and compromises the system.

Recommendation
Do not use more than one dynamic type in abi.encodePacked() Use abi.encode(), preferably.

*/

contract Sign {
    function get_hash_for_signature(string name, string doc) external returns(bytes32) {
        return keccak256(abi.encodePacked(name, doc));
    }
}
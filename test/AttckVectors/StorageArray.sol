// SPDX-License-Identifier: UNLICENSED
/*
Name: Modifying storage array by value

For instance the contract below: Bob calls f().Bob assumes that at the end of the call x[0] is 2,
but it is 1. As a result, Bob's usage of the contract is incorrect.

Recommendation
Ensure the correct usage of memory and storage in the function parameters. Make all the locations explicit.
*/

contract Memory {
    uint[1] public x; // storage

    function f() public {
        f1(x); // update x
        f2(x); // do not update x
    }

    function f1(uint[1] storage arr) internal { // by reference
        arr[0] = 1;
    }

    function f2(uint[1] arr) internal { // by value
        arr[0] = 2;
    }
}
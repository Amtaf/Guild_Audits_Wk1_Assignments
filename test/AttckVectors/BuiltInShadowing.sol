// SPDX-License-Identifier: AGPL-3.0-only
/*
Name: Builtin symbol shadowing

Local variables,functions,modifiers or events with names that shadow built in solidity symbols such as 'now' and 'assert' 
now is defined as a state variable, and shadows with the built-in symbol now. The function assert overshadows the built-in
assert function. Any use of either of these built-in symbols may lead to unexpected results.
*/

pragma solidity ^0.4.24;

contract Bug {
    uint now; // Overshadows current time stamp.

    function assert(bool condition) public {
        // Overshadows built-in symbol for providing assertions.
    }

    function get_next_expiration(uint earlier_time) private returns (uint) {
        return now + 259200; // References overshadowed timestamp.
    }
}
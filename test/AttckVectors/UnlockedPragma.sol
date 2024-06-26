// SPDX-License-Identifier: UNLICENSED
/*
Name:Unlocked pragma

Contracts should be deployed using the same compiler version/flags with which they have been tested. 
Locking the pragma (for e.g. by not using ^ in pragma solidity 0.5.10) ensures that contracts do not accidentally 
get deployed using an older compiler version with unfixed bugs. 
*/

//floating_pragma
pragma solidity ^0.4.0;

contract PragmaNotLocked {
    uint public x = 1;
}

//floating_pragma_fixed
pragma solidity 0.4.25;

contract PragmaFixed {
    uint public x = 1;
}
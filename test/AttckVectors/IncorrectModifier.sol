// SPDX-License-Identifier: UNLICENSED
/*
Name: Incorrect Modifier
If a modifier does not execute _ or revert, the execution of the function will return the default value,
which can be misleading for the caller.
*/

    modidfier myModif(){
        if(..){
           _;
        }
    }
    function get() myModif returns(uint){

    }
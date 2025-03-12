// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PiggyVest} from "./../src/PiggyVest.sol";


contract DeployPiggyVest is Script {
    function run() external {
        
        vm.startBroadcast();

        
        PiggyVest piggy = new PiggyVest(
        );

      
        vm.stopBroadcast();

       
        console.log("PiggyVest deployed at:", address(piggy));
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {PiggyVest} from "./../src/PiggyVest.sol";

contract PiggyContributionTest is Test {
    PiggyVest public piggy;
    address public owner = address(0x123);
    address public contributor = address(0x456);

    function setUp() public {
        vm.prank(owner);
        piggy = new PiggyVest(
            1 ether, 
            10 ether, 
        );
    }

    function testCheckIfAddressHasNFT() public {
        vm.prank(contributor);
        vm.deal(contributor, 1 ether);
        piggy.contribute{value: 1 ether}();

        // Check if the contributor has an NFT
        bool hasNFT = piggy.checkIfAddressHasNFT(contributor);
        assertTrue(hasNFT, "Contributor should have an NFT");
    }
}

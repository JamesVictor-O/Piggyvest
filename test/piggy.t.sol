// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { PiggyVest} from "./../src/PiggyVest.sol"; // Update path if needed;


contract PiggyVestTest is Test {
    PiggyVest public piggyVest;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        // Deploy the PiggyVest contract
        piggyVest = new PiggyVest();

        // Set up test accounts
        owner = address(this); // Test contract is the owner
        user1 = address(0x123);
        user2 = address(0x456);

        // Fund test accounts with ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    // ====================
    // Test Creating a Party
    // ====================

    function testCreateParty() public {
        // Create a new party
        piggyVest.createParty(10 ether, 1 ether);

        // Check party details
        (uint partyId, uint contributedAmount, uint amountToContribute, uint targetAmount, bool poolStatus, address creator, uint memberCount) = piggyVest.parties(1);
        assertEq(partyId, 1, "Party ID mismatch");
        assertEq(contributedAmount, 0, "Contributed amount mismatch");
        assertEq(amountToContribute, 1 ether, "Amount to contribute mismatch");
        assertEq(targetAmount, 10 ether, "Target amount mismatch");
        assertEq(poolStatus, true, "Pool status should be active");
        assertEq(creator, owner, "Creator address mismatch");
        assertEq(memberCount, 0, "Member count mismatch");
    }

    // ====================
    // Test Contributing to a Party
    // ====================

    function testContribute() public {
        // Create a new party
        piggyVest.createParty(10 ether, 1 ether);

        // User1 contributes to the party
        vm.prank(user1);
        piggyVest.contribute{value: 1 ether}(1);

        // Check contributor details
        (uint amount, uint timestamp) = piggyVest.contributorsList(1, user1);
        assertEq(amount, 1 ether, "Contribution amount mismatch");
        assertEq(timestamp, block.timestamp, "Timestamp mismatch");

        // Check party details
        (, uint contributedAmount, , , , , uint memberCount) = piggyVest.parties(1);
        assertEq(contributedAmount, 1 ether, "Contributed amount mismatch");
        assertEq(memberCount, 1, "Member count mismatch");

        // Check NFT ownership
        uint tokenId = piggyVest.memberTokens(user1, 1);
        assertEq(piggyVest.ownerOf(tokenId), user1, "NFT not minted to user1");
    }

    // ====================
    // Test Checking NFT Ownership
    // ====================

    function testCheckIfAddressHasNFT() public {
        // Create a new party
        piggyVest.createParty(10 ether, 1 ether);

        // User1 contributes to the party
        vm.prank(user1);
        piggyVest.contribute{value: 1 ether}(1);

        // Check if user1 has an NFT
        bool hasNFT = piggyVest.checkIfAddressHasNFT(user1);
        assertTrue(hasNFT, "User1 should have an NFT");

        // Check if user2 has an NFT
        bool hasNFTUser2 = piggyVest.checkIfAddressHasNFT(user2);
        assertFalse(hasNFTUser2, "User2 should not have an NFT");
    }

    // ====================
    // Test Toggling Pool Status
    // ====================

    function testTogglePoolStatus() public {
        // Create a new party
        piggyVest.createParty(10 ether, 1 ether);

        // Toggle pool status
        piggyVest.togglePoolStatus(1);

        // Check if pool status is toggled
        (, , , , bool poolStatus, , ) = piggyVest.parties(1);
        assertEq(poolStatus, false, "Pool status should be inactive");
    }

    // ====================
    // Test Withdrawing Contributions
    // ====================

     function testWithdrawContribution() public {
        // Create a new party
        piggyVest.createParty(10 ether, 1 ether);

        // User1 contributes to the party
        vm.prank(user1);
        piggyVest.contribute{value: 1 ether}(1);

        // Check the contract balance before withdrawal
        uint contractBalanceBefore = address(piggyVest).balance;
        assertEq(contractBalanceBefore, 1 ether, "Contract balance mismatch before withdrawal");

        // Check the owner's balance before withdrawal
        uint ownerBalanceBefore = owner.balance;

        // Withdraw contributions
        piggyVest.withdrawContribution();

        // Check the contract balance after withdrawal
        uint contractBalanceAfter = address(piggyVest).balance;
        assertEq(contractBalanceAfter, 0, "Contract balance should be zero after withdrawal");

        // Check the owner's balance after withdrawal
        uint ownerBalanceAfter = owner.balance;
        assertEq(ownerBalanceAfter, ownerBalanceBefore + 1 ether, "Owner balance mismatch after withdrawal");
    }


    // ====================
    // Test Fetching All Parties
    // ====================

    function testGetAllParties() public {
        // Create two parties
        piggyVest.createParty(10 ether, 1 ether);
        piggyVest.createParty(20 ether, 2 ether);

        // Fetch all parties
        PiggyVest.Party[] memory allParties = piggyVest.getAllParties();

        // Check the number of parties
        assertEq(allParties.length, 2, "Number of parties mismatch");

        // Check details of the first party
        assertEq(allParties[0].partyId, 1, "Party ID mismatch");
        assertEq(allParties[0].targetAmount, 10 ether, "Target amount mismatch");

        // Check details of the second party
        assertEq(allParties[1].partyId, 2, "Party ID mismatch");
        assertEq(allParties[1].targetAmount, 20 ether, "Target amount mismatch");
    }
}
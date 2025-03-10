// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyVest is ERC721, Ownable {
    uint public immutable contributionAmount; 
    uint public immutable targetAmount; 
    bool public poolStatus;

    uint public contributorsId = 0; 
    event NewContribution(address indexed contributor, uint256 tokenId);

  
    struct Contributor {
        uint32 timestamp; 
        uint96 amount;
    }

    mapping(address => Contributor) public contributorsList; 

    constructor(
        uint _contributionAmount,
        uint _targetAmount
    ) ERC721("PiggyContributionNFT", "PCNFT") Ownable(msg.sender) {
        contributionAmount = _contributionAmount;
        targetAmount = _targetAmount;
    }

    function contribute() external payable {
        require(msg.value >= contributionAmount, "Insufficient funds");
        require(poolStatus, "Pool is not active");

        contributorsId++; 
        _safeMint(msg.sender, contributorsId); 

       
        contributorsList[msg.sender] = Contributor({
            timestamp: uint32(block.timestamp), 
            amount: uint96(msg.value) 
        });

        emit NewContribution(msg.sender, contributorsId);
    }

    function withdrawContribution() external onlyOwner {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(owner()).transfer(address(this).balance); 
    }

    function checkIfAddressHasNFT(address user) external view returns (bool) {
        return balanceOf(user) > 0; 
    }

   
    function isPoolActive() external view returns (bool) {
        return poolStatus;
    }
}
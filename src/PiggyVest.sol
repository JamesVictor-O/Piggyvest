// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyVest is ERC721URIStorage, Ownable {
    uint public contributorsId = 0;
    uint public nextPartyId = 0;

    struct Contributor {
        uint amount;
        uint timestamp;
    }

    struct Party {
        uint partyId;
        uint contributedAmount;
        uint amountToContribute;
        uint targetAmount;
        bool poolStatus;
        address creator;
        uint memberCount;
    }
    mapping(uint => mapping(address => Contributor)) public contributorsList;
    mapping(uint => Party) public parties;
    mapping(uint256 => uint256) public tokenIdToLevels;
    mapping(address => mapping(uint => uint256)) public memberTokens;
    mapping(uint256 => uint) public tokenToParty; 

    event NewContribution(
        uint indexed partyId,
        address indexed contributor,
        uint indexed contributorId
    );
    

    constructor() ERC721("PiggyContributionNFT", "PCNFT") Ownable(msg.sender) {}

    function createParty(
        uint256 _targetAmount,
        uint _amountToContribute
    ) external {
        require(_targetAmount > 0, "Target amount must be greater than 0");
        require(
            _amountToContribute > 0,
            "Contribution amount must be greater than 0"
        );
        nextPartyId++;

      parties[nextPartyId] = Party({
            partyId: nextPartyId,
            amountToContribute: _amountToContribute,
            contributedAmount: 0,
            targetAmount: _targetAmount,
            poolStatus: true,
            creator: msg.sender,
            memberCount: 0
        });
    }

    function contribute(uint _partyId) external payable {
        Party storage party = parties[_partyId];
        require(party.partyId > 0, "Party does not exist");
        require(msg.value >= party.amountToContribute, "Insufficient funds");
        require(party.poolStatus, "Pool is not active");
        require(
            party.contributedAmount + msg.value <= party.targetAmount,
            "Contribution would exceed target amount"
        );

        contributorsId++;

        _mint(msg.sender, contributorsId);
        _setTokenURI(contributorsId, getTokenURI(contributorsId));

        contributorsList[_partyId][msg.sender] = Contributor({
            amount: msg.value,
            timestamp: block.timestamp
        });

         party.contributedAmount += msg.value;
        
        party.memberCount++;
        memberTokens[msg.sender][_partyId] = contributorsId;
        tokenToParty[contributorsId] = _partyId;
        tokenIdToLevels[contributorsId] = 0;
        
    }





    function withdrawContribution() external onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "Withdrawal failed");
    }

    function checkIfAddressHasNFT(address user) external view returns (bool) {
        return balanceOf(user) > 0;
    }

    function isPoolActive(uint _partyId) external view returns (bool) {
        return parties[_partyId].poolStatus;
    }

    function togglePoolStatus(uint _partyId) external {
        Party storage party = parties[_partyId];
        require(
            msg.sender == party.creator,
            "Only the party creator can toggle the status"
        );
        party.poolStatus = !party.poolStatus;
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToLevels[tokenId];
        return Strings.toString(levels);
    }

    function generateCharacter(
        uint256 tokenId
    ) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "piggy vest #',
            Strings.toString(tokenId),
            '",',
            '"description": "parties on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function getAllParties() public view returns (Party[] memory) {
        Party[] memory allParties = new Party[](nextPartyId);
        for (uint i = 1; i <= nextPartyId; i++) {
            allParties[i - 1] = parties[i];
        }
        return allParties;
    }
}

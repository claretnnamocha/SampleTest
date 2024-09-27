// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SNFT is ERC721, Ownable2Step, ReentrancyGuard {
    uint256 private _nextTokenId;

    // Define an event for minting tokens
    event TokenMinted(address indexed owner, uint256 indexed tokenId);

    constructor() payable ERC721("Sample NFT", "SNFT") Ownable(msg.sender) {}

    function safeMint(address to) public nonReentrant onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        // Emit the TokenMinted event
        emit TokenMinted(to, tokenId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// THIS CONTRACT IS FOR TESTING PURPOSES AND IS NOT PART OF THE PROJECT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FakeToken is ERC721, Ownable {

    constructor() ERC721("Fake Test Token", "FAKE") {}

    function safeMint(address to, uint256 id) public onlyOwner {
        _safeMint(to, id);
    }
}

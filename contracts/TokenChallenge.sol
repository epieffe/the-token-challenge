// SPDX-License-Identifier: MIT
// Based on OpenZeppelin ERC721 implementation
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./utils/ERC721Single.sol";
import "./utils/ERC2981Global.sol";

/**
 * @dev ERC721 token contract with one single token. This single token is locked
 * in the token contract itself and can only be unlocked by transfering a key token
 * to the token contract by calling {IERC721-safeTransferFrom}. The address that
 * unlocks the single token also withdraws all the token contract balance.
 */
contract TokenChallenge is ERC721Single, ERC2981Global, Ownable, IERC721Receiver {

    string private constant NAME = "Token Hacker Challenge";
    string private constant SYMBOL = "THC";
    string private constant TOKEN_URI = "ipfs://bafkreiadflw5nc747gf2vxn6sw5kkit5mef7sn4agx6pdhfmn7c6ahlfmy";

    address public keyTokenAddress;
    uint256 public keyTokenId;

    constructor(
        address keyAddress,
        uint256 keyId
    ) ERC721Single(NAME, SYMBOL, TOKEN_URI) {
        keyTokenAddress = keyAddress;
        keyTokenId = keyId;
        // Set token royalty to 10%
        _setRoyalty(_msgSender(), 1000);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Single, ERC2981Global) returns (bool) {
        return
            ERC721Single.supportsInterface(interfaceId) ||
            ERC2981Global.supportsInterface(interfaceId);
    }

    /**
     * This is called when an ERC721 token is transfered to this contract using {IERC721-safeTransferFrom}.
     * If key token is received the challenge prize is unlocked, otherwise transaction is reverted.
     * The address that receives the prize can be specified in `data`. If not specified the prize is
     * sent to `operator`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4) {
        require (
            msg.sender == address(keyTokenAddress) && tokenId == keyTokenId,
            "received invalid token"
        );
        address winner;
        if (data.length == 0) {
            winner = operator;
        } else {
            require(data.length == 20, "data is not address or empty");
            assembly {winner := mload(add(data, 20))}
        }
        _safeTransfer(address(this), winner, TOKEN_ID, "");
        Address.sendValue(payable(winner), address(this).balance);
        return this.onERC721Received.selector;
    }
}

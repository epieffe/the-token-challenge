// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./utils/ERC721Single.sol";
import "./utils/ERC2981Global.sol";

/**
 * @title Token Hacker Challenge
 * @dev ERC721 token contract with one single token. The single token is locked in
 * this contract and can only be unlocked by transfering a key token to this contract
 * by calling {IERC721-safeTransferFrom}. The address that unlocks the single token
 * also withdraws all the balance of this contract.
 * @author epieffe.eth
 */
contract TokenChallenge is ERC721Single, ERC2981Global, Ownable, IERC721Receiver {

    string private constant NAME = "Token Hacker Challenge";
    string private constant SYMBOL = "THC";
    string private constant TOKEN_URI = "ipfs://bafkreiadflw5nc747gf2vxn6sw5kkit5mef7sn4agx6pdhfmn7c6ahlfmy";

    /**
     * @notice The key token contract.
     */
    IERC721 public keyContract;

    /**
     * @notice The key token id.
     */
    uint256 public keyId;

    constructor(
        IERC721 _keyContract,
        uint256 _keyId
    ) ERC721Single(NAME, SYMBOL, TOKEN_URI) {
        keyContract = _keyContract;
        keyId = _keyId;
        // Set token royalty to 10%
        _setRoyalty(_msgSender(), 1000);
    }

    /**
     * @notice Detects what interfaces this contract implements.
     * @dev See {IERC165-supportsInterface}.
     * @return true if this contract implements input interface
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Single, ERC2981Global) returns (bool) {
        return
            ERC721Single.supportsInterface(interfaceId) ||
            ERC2981Global.supportsInterface(interfaceId);
    }

    /**
     * @notice Received Ether is used to pay the challenge winner.
     * @dev If Eher is received after the challenge is completed, then transaction is reverted.
     */
    receive() external payable {
        require(ownerOf(TOKEN_ID) == address(this));
    }

    /**
     * @notice Pays challenge winner when key token is received.
     * @dev This is called by the key token contract when the key token is transfered to this
     * contract using {IERC721-safeTransferFrom}. If key token is received, the challenge prize
     * is unlocked, otherwise transaction is reverted. The address to send the prize to can be
     * specified in `data`. If not specified the prize is sent to `operator`.
     * @param operator Address that performed the token transfer to this contract
     * @param from Address from where the token was transfered
     * @param tokenId Id of the received token
     * @param data Byte encoded address to send the prize to. If empty prize is sent to operator
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4) {
        require (
            msg.sender == address(keyContract) && tokenId == keyId,
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

    /**
     * @notice Allows contract owner to update the royalty information.
     * @dev Royalty is specified in basis points.
     */
    function setRoyalty(address receiver, uint96 royaltyFraction) external virtual onlyOwner {
        _setRoyalty(receiver, royaltyFraction);
    }

    /**
     * @notice Allows contract owner to withdraw the key token from the contract.
     */
    function withdrawKeyToken(address receiver) external virtual onlyOwner {
        keyContract.safeTransferFrom(address(this), receiver, keyId);
    }
}

// SPDX-License-Identifier: MIT
// Based on OpenZeppelin ERC721 implementation

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the NFT Royalty Standard, a standardized way to retrieve royalty payment information.
 * Royalty information is specified globally for all token ids.
 * Royalty is specified in basis points.
 *
 * IMPORTANT: ERC-2981 only specifies a way to signal royalty information and does not enforce its payment. See
 * https://eips.ethereum.org/EIPS/eip-2981#optional-royalty-payments[Rationale] in the EIP. Marketplaces are expected to
 * voluntarily pay royalties together with sales, but note that this standard is not yet widely supported.
 */
abstract contract ERC2981Global is IERC2981, ERC165 {

    uint96 constant private FEE_DENOMINATOR = 10000;

    address private _receiver;
    uint96 private _royaltyFraction;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address, uint256) {
        uint256 royaltyAmount = (_salePrice * _royaltyFraction) / FEE_DENOMINATOR;
        return (_receiver, royaltyAmount);
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     *
     * Requirements:
     *
     * - `receiver` cannot be the zero address.
     * - `royaltyFraction` cannot be greater than 10000.
     */
    function _setRoyalty(address receiver, uint96 royaltyFraction) internal virtual {
        require(royaltyFraction <= FEE_DENOMINATOR, "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");
        _receiver = receiver;
        _royaltyFraction = royaltyFraction;
    }
}

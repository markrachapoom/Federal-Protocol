// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./utils/NFT.sol";
import "./utils/Taxes.sol";

/// @title Federal Contract
/// @author kumareth@Federal.app
/// @notice This contract shall be the prime Federal NFT contract for creation of contracts in the Metaverse!
contract Federal is NFT, Taxes, ReentrancyGuard {

    /// @notice Constructor function for the Federal Contract
    /// @dev Constructor function for the Federal ERC721 Contract
    /// @param name_ Name of the Federal artifact Collection
    /// @param symbol_ Symbol for the Federal NFTs
    /// @param _permissionManagementContractAddress Address of the PermissionManagement Contract that manages Permissions.
    constructor(
        string memory name_, 
        string memory symbol_,
        address _permissionManagementContractAddress,
        string memory contractURI_
    )
    NFT(name_, symbol_, _permissionManagementContractAddress, contractURI_)
    Taxes(_permissionManagementContractAddress)
    payable
    {
        // Build Genesis Artifact and Zero Token
        //
    }




    // token IDs counter
    using Counters for Counters.Counter;
    Counters.Counter public totalTokensMinted;




    // Used to Split Royalty
    // See EIP-2981 for more information: https://eips.ethereum.org/EIPS/eip-2981
    struct RoyaltyInfo {
        address receiver;
        uint256 percent; // it's actually a permyriad (parts per ten thousand)
    }
    mapping(uint256 => RoyaltyInfo) public getRoyaltyInfoByTokenId;

    /// @notice returns royalties info for the given Token ID
    /// @dev can be used by other contracts to get royaltyInfo
    /// @param _tokenID Token ID of which royaltyInfo is to be fetched
    /// @param _salePrice Desired Sale Price of the token to run calculations on
    function royaltyInfo(uint256 _tokenID, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory rInfo = getRoyaltyInfoByTokenId[_tokenID];
        if (rInfo.receiver == address(0)) return (address(0), 0);
        uint256 amount = _salePrice * rInfo.percent / 10000;
        return (payable(rInfo.receiver), amount);
    }




    // Events
    //




    // Modifiers
    //




    // Public Functions
    //
}
// SPDX-License-Identifier: ISC
pragma solidity >=0.4.22 <0.9.0;

import "../PermissionManagement.sol";

/// @title Max Gas Price Checker
/// @author hey@kumareth.com
/// @notice Used to stop Front Runner attacks in a Market
/// @dev Admins can set MaxGasPrice, allowing Functions to fail if the set Gas Price exceeds.
abstract contract MaxGasPrice {
  PermissionManagement private permissionManagement;

  constructor (
    address _permissionManagementContractAddress
  ) {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
  }

  uint256 public maxGasPrice = 1 * 10 ** 18;

  modifier validGasPrice() {
    require(
        tx.gasprice <= maxGasPrice,
        "Max Gas Price Exceeded"
    );
    _;
  }

  function setMaxGasPrice(uint256 newMax)
    public
    returns (bool) 
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    maxGasPrice = newMax;
    return true;
  }
}
// SPDX-License-Identifier: ISC
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../PermissionManagement.sol";
import "./Payable.sol";

/// @title Coin Contract
/// @author hey@kumareth.com
/// @notice An ERC20 Contract
contract Coin is ERC20, Payable {
  PermissionManagement internal permissionManagement;

  constructor (
    string memory name_, 
    string memory symbol_,
    address _permissionManagementContractAddress
  )
  ERC20(name_, symbol_)
  Payable(_permissionManagementContractAddress)
  {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
  }

  function mint(uint256 amount) external returns (uint256 _amount) {
    _mint(msg.sender, amount);
    return amount;
  }
}

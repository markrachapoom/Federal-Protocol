// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PermissionManagement.sol";
import "./Escrow.sol";

/// @title The Escrow Factory Contract
/// @author kumareth@federal.app
/// @notice This is the Minimal Escrow Proxy Factory Contract
contract EscrowFactory is ReentrancyGuard {
    PermissionManagement private permissionManagement;

    address public escrowContractAddress;
    address[] public allProxies;

    event NewProxy (address indexed contractAddress);

    constructor (
        address _escrowContractAddress, 
        address _permissionManagementContractAddress
    ) {
        escrowContractAddress = _escrowContractAddress;
        permissionManagement = PermissionManagement(_permissionManagementContractAddress);
    }

    function _clone() internal returns (address result) {
        bytes20 targetBytes = bytes20(escrowContractAddress);

        //-> learn more: https://coinsbench.com/minimal-proxy-contracts-eip-1167-9417abf973e3 & https://medium.com/coinmonks/diving-into-smart-contracts-minimal-proxy-eip-1167-3c4e7f1a41b8
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }

        require(result != address(0), "ERC1167: clone failed");
    }

    function createProxy(
        address _payer,
        address _beneficiary,
        address _judge
    ) external nonReentrant returns (address result) {
        permissionManagement.adhereToBanMethod(msg.sender);
        address proxy = _clone();
        allProxies.push(proxy);
        Escrow(payable(proxy)).initialize(_payer, _beneficiary, _judge);
        emit NewProxy (proxy);
        return proxy;
    }

    function changeEscrowContractAddress(address _escrowContractAddress) 
        external
        nonReentrant
        returns(address)
    {
        permissionManagement.adminOnlyMethod(msg.sender);
        escrowContractAddress = _escrowContractAddress;
        return _escrowContractAddress;
    }
}
// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Federal.sol";
import "./PermissionManagement.sol";
import "./utils/NFT.sol";
import "./utils/Payable.sol";

/// @title Federal Marketplace Contract
/// @author kumareth@federal.app
/// @notice In federal.app context, this contract becomes an Automated Market Maker for the Artifacts minted in the federal Metaverse
contract Marketplace is Payable, ReentrancyGuard {
  PermissionManagement private permissionManagement;

  constructor (
    address _permissionManagementContractAddress,
    address payable _allowedNFTContractAddress
  )
  Payable(_permissionManagementContractAddress)
  payable
  {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
    
    allowedNFTContractAddress = _allowedNFTContractAddress;
    allowedNFTContract = Federal(_allowedNFTContractAddress);

    // create a genesis fake auction that expires quickly for avoiding out of bounds error
    _enableAuction(10 ** 18, 0, 0);

    // create a genesis $0 fake internal order that expires in 60 seconds for avoiding blank zero mapping conflict
    _placeOrder(0, 60);
    orders[0].tokenId = 10 ** 18;
    orders[0].price = 0;
  }




  // Auction IDs Counter
  using Counters for Counters.Counter;
  Counters.Counter public totalAuctions;




  // Manage what NFTs can be bought and sold in the marketplace
  address public allowedNFTContractAddress;
  Federal allowedNFTContract;
  
  function changeAllowedNFTContract(address payable _nftContractAddress) 
    external
    returns(address)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    allowedNFTContractAddress = _nftContractAddress;
    allowedNFTContract = Federal(_nftContractAddress);
    return _nftContractAddress;
  }




  // Taxes
  uint256 public taxOnEverySaleInPermyriad = 0;

  function changeTaxOnEverySaleInPermyriad(uint256 _taxOnEverySaleInPermyriad) 
    external
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    require(_taxOnEverySaleInPermyriad <= 10000, "Permyriad value out of bounds");
    taxOnEverySaleInPermyriad = _taxOnEverySaleInPermyriad;
    return _taxOnEverySaleInPermyriad;
  }




  // Events
  event EnabledAuction(
    uint256 indexed id,
    uint256 indexed _tokenId,
    uint256 _basePrice,
    uint256 _auctionExpiryTime,
    address indexed _enabledBy,
    uint256 _timestamp
  );
  event EndedAuction(
    uint256 indexed id,
    uint256 indexed _tokenId,
    address indexed _endedBy,
    uint256 _timestamp
  );
  event EnabledAutoSell(
    uint256 indexed _tokenId,
    uint256 _price,
    address indexed _enabledBy,
    uint256 _timestamp
  );
  event DisabledAutoSell(
    uint256 indexed _tokenId,
    address indexed _disabledBy,
    uint256 _timestamp
  );
  event OrderPlaced(
    uint256 indexed id,
    address indexed buyer,
    uint256 indexed tokenId,
    uint256 price,
    uint256 createdAt,
    uint256 expiresAt,
    address placedBy
  );
  event OrderExecuted(
    uint256 indexed id,
    uint256 indexed tokenId,
    uint256 timestamp
  );
  event OrderCancelled(
    uint256 indexed id,
    uint256 indexed tokenId,
    uint256 timestamp
  );




  // Enable/Disable Autosell, and Auction Management

  struct Auction {
    uint256 id;
    uint256 tokenId;
    uint256 basePrice;
    uint256 highestBidOrderId;
    uint256 startTime;
    uint256 expiryTime;
  }
  Auction[] public auctions;

  mapping(uint256 => uint256) public getTokenPrice;
  mapping(uint256 => bool) public isTokenAutoSellEnabled;

  mapping(uint256 => bool) public isTokenAuctionEnabled;
  mapping(uint256 => uint256) public getLatestAuctionIDByTokenID;
  mapping(uint256 => uint256[]) public getAuctionIDsByTokenID;

  /// @notice Allows Token Owner to List the Tokens on the Marketplace with Auction Enabled
  /// @param _tokenIds IDs of the Tokens to List on the Market with Selling Auto-Enabled
  /// @param _basePrice Minimum Price one must put to Bid in the Auction.
  /// @param _auctionExpiresIn Set an End Time for the Auction
  function enableAuction(
    uint256[] memory _tokenIds,
    uint256 _basePrice,
    uint256 _auctionExpiresIn
  ) nonReentrant external returns(uint256[] memory, uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(
        allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "unauthorized enableAuction"
      );

      // if auction is already on, err
      require(isTokenAuctionEnabled[_tokenId] != true, "Token already in auction");

      _enableAuction(
        _tokenId,
        _basePrice,
        _auctionExpiresIn
      );
    }

    return (_tokenIds, _basePrice);
  }

  function _enableAuction(
    uint256 _tokenId,
    uint256 _basePrice,
    uint256 _auctionExpiresIn
  ) private returns(uint256, uint256, uint256) {
    getTokenPrice[_tokenId] = _basePrice;
    isTokenAutoSellEnabled[_tokenId] = false;

    uint256 newAuctionId = totalAuctions.current();
    totalAuctions.increment();

    isTokenAuctionEnabled[_tokenId] = true;
    auctions.push(
      Auction(
        newAuctionId,
        _tokenId,
        _basePrice,
        0,
        block.timestamp,
        block.timestamp + _auctionExpiresIn
      )
    );
    getLatestAuctionIDByTokenID[_tokenId] = newAuctionId;
    getAuctionIDsByTokenID[_tokenId].push(newAuctionId);

    emit EnabledAuction(
      newAuctionId,
      _tokenId,
      _basePrice,
      block.timestamp + _auctionExpiresIn,
      msg.sender,
      block.timestamp
    );

    return (_tokenId, _basePrice, _auctionExpiresIn);
  }

  /// @notice Allows Token Owner or the Auction Winner to Execute the Auction of their Token
  /// @param _tokenId ID of the Token whose Auction to end
  function executeAuction(
    uint256 _tokenId
  ) nonReentrant external returns(uint256, uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    // cant execute an auction that never started
    require(isTokenAuctionEnabled[_tokenId] == true, "Token not auctioned");

    // if auction didn't end by time yet
    if (block.timestamp <= auctions[getLatestAuctionIDByTokenID[_tokenId]].expiryTime) {
      // allow only moderators or owner or approved to execute the auction
      require(
        permissionManagement.moderators(msg.sender) == true || 
        allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
        allowedNFTContract.getApproved(_tokenId) == msg.sender, 
        "You cant execute this auction just yet"
      );

    // if auction expired/ended
    } else {
      // allow only auction winner or moderators or owner or approved to execute the auction
      require(
        permissionManagement.moderators(msg.sender) == true || 
        allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].buyer == msg.sender,
        "You arent allowed to execute this auction"
      );
    }

    return _executeAuction(_tokenId);
  }

  function _executeAuction(
    uint256 _tokenId
  ) private returns(uint256, uint256) {
    // if there is a valid highest bid
    uint256 _orderId;
    if (auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId != 0) {
        // check if auction winner funded more than or equal to the base price
        if (
          orders[
            auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId
          ].price
            >=
          auctions[getLatestAuctionIDByTokenID[_tokenId]].basePrice
        ) {
          // give the token to the auction winner and carry the transaction
          _orderId = _executeOrder(auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId);

          allowedNFTContract.marketTransfer(
            allowedNFTContract.ownerOf(_tokenId),
            orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].buyer, 
            _tokenId
          );
        }
    }

    isTokenAutoSellEnabled[_tokenId] = false;
    isTokenAuctionEnabled[_tokenId] = false;

    emit EndedAuction(
      getLatestAuctionIDByTokenID[_tokenId],
      _tokenId,
      msg.sender,
      block.timestamp
    );
    
    return (_tokenId, _orderId);
  }

  /// @notice Allows Token Owner to List their Tokens on the Marketplace with Automated Selling
  /// @param _tokenIds ID of the Token to List on the Market with Selling Auto-Enabled
  /// @param _pricePerToken At what Price in Wei, if an Order recevied, should be automatically executed?
  function enableAutoSell(
    uint256[] memory _tokenIds,
    uint256 _pricePerToken
  ) nonReentrant external returns(uint256[] memory, uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(
        allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "unauthorized enableAutoSell"
      );

      // if auction is already on, it must be executed first
      require(isTokenAuctionEnabled[_tokenId] != true, "Token already in auction");

      getTokenPrice[_tokenId] = _pricePerToken;
      isTokenAutoSellEnabled[_tokenId] = true;
      isTokenAuctionEnabled[_tokenId] = false;

      emit EnabledAutoSell(
        _tokenId,
        _pricePerToken,
        msg.sender,
        block.timestamp
      );
    }

    return (_tokenIds, _pricePerToken);
  }

  /// @notice Allows Token Owner to Disable Auto Selling of their Tokens
  /// @param _tokenIds IDs of the Tokens to List on the Market with Auto-Selling Disabled
  function disableAutoSell(
    uint256[] memory _tokenIds
  ) nonReentrant external returns(uint256[] memory) {
    permissionManagement.adhereToBanMethod(msg.sender);

    for (uint256 i = 0; i < _tokenIds.length; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(
        allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "unauthorized disableAutoSell"
      );

      // if auction is already on, it must be executed first
      require(isTokenAuctionEnabled[_tokenId] != true, "Token is in an auction");

      _disableAutoSell(_tokenId);
    }

    return _tokenIds;
  }

  function _disableAutoSell(
    uint256 _tokenId
  ) internal returns(uint256) {
    isTokenAutoSellEnabled[_tokenId] = false;
    isTokenAuctionEnabled[_tokenId] = false;

    emit DisabledAutoSell(
      _tokenId,
      msg.sender,
      block.timestamp
    );

    return _tokenId;
  }




  // Orders Management

  struct Order {
    uint256 id;
    address payable buyer;
    uint256 tokenId;
    uint256 price;
    uint256 createdAt;
    uint256 expiresAt;
    address payable placedBy;
    bool isDuringAuction;
  }

  enum OrderStatus { PLACED, EXECUTED, CANCELLED }

  Order[] public orders;

  // tokenId to orderId[] mapping
  mapping (uint256 => uint256[]) public getOrderIDsByTokenID;

  // orderId to OrderStatus mapping
  mapping (uint256 => OrderStatus) public getOrderStatus;




  // Internal Functions relating to Order Management

  function _placeOrder(
    uint256 _tokenId,
    uint256 _expireInSeconds
  ) private returns(uint256) {
    require(allowedNFTContract.ownerOf(_tokenId) != msg.sender, "You cant place an order on your own token");

    uint256 _orderId = orders.length;

    Order memory _order = Order({
      id: _orderId,
      buyer: payable(msg.sender),
      tokenId: _tokenId,
      price: msg.value,
      createdAt: block.timestamp,
      expiresAt: block.timestamp + _expireInSeconds,
      placedBy: payable(msg.sender),
      isDuringAuction: isTokenAuctionEnabled[_tokenId]
    });

    orders.push(_order);
    getOrderIDsByTokenID[_tokenId].push(_order.id);
    getOrderStatus[_orderId] = OrderStatus.PLACED;

    if (msg.value > orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].price) {
      auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId = _orderId;
    }

    emit OrderPlaced(
      _order.id,
      _order.buyer,
      _order.tokenId,
      _order.price,
      _order.createdAt,
      _order.expiresAt,
      _order.placedBy
    );

    return _orderId;
  }

  function _placeOffer(
    uint256 _tokenId,
    uint256 _expireInSeconds,
    address _buyer,
    uint256 _price
  ) private returns(uint256) {
    require(
      allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
      allowedNFTContract.getApproved(_tokenId) == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "You do not have rights to offer this token"
    );
    require(_buyer != msg.sender, "You cant make an offer to yourself");

    uint256 _orderId = orders.length;

    Order memory _order = Order({
      id: _orderId,
      buyer: payable(_buyer),
      tokenId: _tokenId,
      price: _price,
      createdAt: block.timestamp,
      expiresAt: block.timestamp + _expireInSeconds,
      placedBy: payable(msg.sender),
      isDuringAuction: isTokenAuctionEnabled[_tokenId]
    });

    orders.push(_order);
    getOrderIDsByTokenID[_tokenId].push(_order.id);
    getOrderStatus[_orderId] = OrderStatus.PLACED;

    emit OrderPlaced(
      _order.id,
      _order.buyer,
      _order.tokenId,
      _order.price,
      _order.createdAt,
      _order.expiresAt,
      _order.placedBy
    );

    return _orderId;
  }

  function _executeOrder(
    uint256 _orderId
  ) private returns(uint256) {
    require(getOrderStatus[_orderId] != OrderStatus.CANCELLED, "Order already cancelled");
    require(getOrderStatus[_orderId] != OrderStatus.EXECUTED, "Order already executed");

    // order that is the current highest bid made during an auction cannot expire
    require(
      block.timestamp <= orders[_orderId].expiresAt || 
      (
        orders[_orderId].isDuringAuction == true && 
        auctions[getLatestAuctionIDByTokenID[orders[_orderId].tokenId]].highestBidOrderId == _orderId
      ), 
      "Order expired"
    );

    require(orders[_orderId].price <= msg.value || orders[_orderId].price <= getBalance(), "Insufficient Contract Balance");

    if (orders[_orderId].price > 0) {
      // calculate and split royalty
      (
        address royaltyReceiver, 
        uint256 royaltyAmount
      ) = allowedNFTContract.royaltyInfo(
        orders[_orderId].tokenId,
        orders[_orderId].price
      );

      if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
        // pay the Splits contract
        (bool success1, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
        require(success1, "Transfer to Splits Contract failed");
      }

      uint256 beneficiaryPay = (orders[_orderId].price - royaltyAmount) * taxOnEverySaleInPermyriad / 10000;

      // pay taxes
      (bool success2, ) = permissionManagement.beneficiary().call{value: beneficiaryPay}("");
      require(success2, "Transfer to Beneficiary failed");

      // pay the owner
      (bool success3, ) = payable(allowedNFTContract.ownerOf(orders[_orderId].tokenId)).call{value: orders[_orderId].price - beneficiaryPay - royaltyAmount}("");
      require(success3, "Transfer to Owner failed");
    }

    getOrderStatus[_orderId] = OrderStatus.EXECUTED;

    _disableAutoSell(orders[_orderId].tokenId);

    emit OrderExecuted(_orderId, orders[_orderId].tokenId, block.timestamp);

    return _orderId;
  }

  function _cancelOrder(
    uint256 _orderId
  ) private returns(uint256) {
    require(getOrderStatus[_orderId] == OrderStatus.PLACED, "Order must be placed to cancel it");

    if (orders[_orderId].price != 0 && orders[_orderId].placedBy == orders[_orderId].buyer) {
      (bool success, ) = orders[_orderId].buyer.call{value: orders[_orderId].price}("");
      require(success, "Transfer to Buyer failed");
    }

    getOrderStatus[_orderId] = OrderStatus.CANCELLED;

    emit OrderCancelled(_orderId, orders[_orderId].tokenId, block.timestamp);

    return _orderId;
  }




  // Public Marketplace Functions

  /// @notice Places Order on a Token
  /// @dev Creates an Order
  /// @param _tokenId Token ID to place an Order On.
  /// @param _expireInSeconds Seconds you want the Order to Expire in.
  function placeOrder(
    uint256 _tokenId,
    uint256 _expireInSeconds
  ) nonReentrant external payable returns(uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);
    require(_expireInSeconds >= 60, "Order must not expire within 60 seconds");
    require(msg.value >= 1, "A non-zero value must be paid");

    uint256 _orderId = _placeOrder(_tokenId, _expireInSeconds);

    // check if token is sellable
    address payable tokenOwner = payable(allowedNFTContract.ownerOf(_tokenId));

    // if sellable, buy
    if (isTokenAutoSellEnabled[_tokenId] == true) {
      // if free, complete transaction
      if (getTokenPrice[_tokenId] == 0) {
        _executeOrder(_orderId);
        allowedNFTContract.marketTransfer(tokenOwner, msg.sender, _tokenId);
        return _orderId;
      }

      // check if offerPrice matches getTokenPrice, if yes, complete transaction.
      if (msg.value >= getTokenPrice[_tokenId]) {
        _executeOrder(_orderId);
        allowedNFTContract.marketTransfer(tokenOwner, msg.sender, _tokenId);
        return _orderId;
      }
    }

    return _orderId;
  }

  /// @notice For Token Owner to Offer a Token to someone
  /// @dev Creates an Offer Order
  /// @param _tokenId Token ID to place an Order On.
  /// @param _expireInSeconds Seconds you want the Order to Expire in.
  /// @param _buyer Prospective Buyer Address
  /// @param _price Price at which the Token Owner aims to sell the Token to the Buyer
  function placeOffer(
    uint256 _tokenId,
    uint256 _expireInSeconds,
    address _buyer,
    uint256 _price
  ) nonReentrant external returns(uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    require(_expireInSeconds >= 60, "Offer must not expire within 60 seconds");

    // if auction is on, token owner cant place offers
    require(isTokenAuctionEnabled[_tokenId] != true, "Cant offer tokens during auction");

    uint256 _orderId = _placeOffer(_tokenId, _expireInSeconds, _buyer, _price);

    return _orderId;
  }

  /// @notice For Token Owner to Approve an Order, or for Buyer to Accept an Offer
  /// @dev Executes an Order on Valid Acceptance
  /// @param _orderId ID of the Order to Accept
  function acceptOffer(
    uint256 _orderId
  ) nonReentrant external payable returns(uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    Order memory _order = orders[_orderId];
    address tokenOwner = allowedNFTContract.ownerOf(_order.tokenId);
    address tokenApprovedAddress = allowedNFTContract.getApproved(_order.tokenId);

    require(_order.placedBy != msg.sender, "You cant accept your own offer");

    // if auction is on, you cant accept random offers
    require(isTokenAuctionEnabled[_order.tokenId] != true, "Cant accept offers on a token during auction");

    // if buyer booked an order for the token owner to approve
    if (_order.placedBy == _order.buyer) {
      require(
        tokenOwner == msg.sender || 
        tokenApprovedAddress == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "Only token owner can accept this offer"
      );

      _executeOrder(_orderId);
      allowedNFTContract.marketTransfer(tokenOwner, _order.buyer, _order.tokenId);
    } else {
      // if token owner/approved address, offered the buyer
      require(_order.buyer == msg.sender, "Only the address that was offered can accept this offer");
      require(_order.placedBy == tokenOwner, "Offer expired as the token is no more owned by the original offerer");

      // require offer price
      require(msg.value >= _order.price, "Insufficient amount sent");

      _executeOrder(_orderId);
      allowedNFTContract.marketTransfer(tokenOwner, _order.buyer, _order.tokenId);

      return _orderId;
    }

    return _orderId;
  }

  /// @notice Allows either party in an Order to cancel the Order
  /// @dev Cancels an Order
  /// @param _orderId ID of the Order to Cancel
  function cancelOffer(
    uint256 _orderId
  ) nonReentrant external returns(uint256) {
    permissionManagement.adhereToBanMethod(msg.sender);

    Order memory _order = orders[_orderId];
    address tokenOwner = allowedNFTContract.ownerOf(_order.tokenId);
    address tokenApprovedAddress = allowedNFTContract.getApproved(_order.tokenId);

    require(_order.createdAt > 0, "Invalid orderId");

    require(
      _order.placedBy == msg.sender || 
      tokenOwner == msg.sender || 
      tokenApprovedAddress == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "You do not have the right to cancel this offer"
    );

    // if your bid was the highest on an auctioned token, and if it was above auction base price, then you cannot cancel
    if (
        auctions[getLatestAuctionIDByTokenID[_order.tokenId]].highestBidOrderId == _orderId &&
        _order.isDuringAuction == true &&
        _order.price >= auctions[getLatestAuctionIDByTokenID[_order.tokenId]].basePrice
    ) {
      revert("Highest Bid cant be cancelled during an Auction");
    }

    _cancelOrder(_orderId);

    return _orderId;
  }
}

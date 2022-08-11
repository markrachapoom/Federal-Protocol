// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./utils/ERC721/IERC721Receiver.sol";

/// @title The Escrow Implementation Contract
/// @author kumareth@federal.app
/// @notice Contract that has all the Escrow logic, which shall be used by the Escrow Factory
contract Escrow is Initializable, ReentrancyGuardUpgradeable, IERC777Recipient, IERC721Receiver {
    constructor () {
        //
    }

    bool public isFreezed;

    address public payer;
    address public beneficiary;
    address public judge;

    address[] public participants;
    mapping(address => bool) public participantExists;

    mapping(address => uint256) public getBalanceOf;
    mapping(address => mapping(address => uint256)) public getERC20BalanceOf;
    mapping(address => mapping(address => uint256[])) public getERC721BalanceOf;

    mapping(address => uint256) public getApprovedBalanceOf;
    mapping(address => mapping(address => uint256)) public getApprovedERC20BalanceOf;
    mapping(address => mapping(address => uint256[])) public getApprovedERC721BalanceOf;

    /// @notice Constructor function for the Escrow Contract Instances
    function initialize(
        address _payer,
        address _beneficiary,
        address _judge
    )
        public 
        payable
        initializer
    {
        require(_payer != _beneficiary);
        payer = _payer;
        beneficiary = _beneficiary;
        judge = _judge;
        isFreezed = false;
    }




    /// @notice Get Balance of the Escrow Contract
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }




    // Events
    event ReceivedFunds(
        address indexed by,
        uint256 fundsInwei,
        uint256 timestamp
    );
    event ReceivedERC721(
        address indexed from,
        address indexed nftContract,
        uint256 tokenId,
        uint256 timestamp
    );
    event ReceivedERC777(
        address indexed from,
        address indexed tokenContract,
        uint256 amount,
        uint256 timestamp
    );
    event EscrowFreezed (uint256 timestamp);
    event EscrowUnfreezed (uint256 timestamp);
    event NewParticipant (address indexed participant, uint256 timestamp);
    event ApprovedFunds (
        address indexed fromAccount,
        address indexed actionedBy,
        address indexed beneficiary,
        uint256 amount,
        uint256 timestamp
    );
    event ApprovedERC721 (
        address indexed fromAccount,
        address actionedBy,
        address indexed beneficiary,
        address indexed contractAddress,
        uint256 tokenId,
        uint256 timestamp
    );
    event ApprovedERC20 (
        address indexed fromAccount,
        address actionedBy,
        address indexed beneficiary,
        address indexed contractAddress,
        uint256 amount,
        uint256 timestamp
    );
    event Refunded (
        address indexed actionedBy,
        address indexed payer,
        uint256 amount,
        uint256 timestamp
    );
    event RefundedERC721 (
        address indexed actionedBy,
        address indexed payer,
        address indexed contractAddress,
        uint256 tokenId,
        uint256 timestamp
    );
    event RefundedERC20 (
        address indexed actionedBy,
        address indexed payer,
        address indexed contractAddress,
        uint256 amount,
        uint256 timestamp
    );
    event Withdrew (
        address indexed actionedBy,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event WithdrewERC721 (
        address indexed actionedBy,
        address indexed to,
        address indexed contractAddress,
        uint256 tokenId,
        uint256 timestamp
    );
    event WithdrewERC20 (
        address indexed actionedBy,
        address indexed to,
        address indexed contractAddress,
        uint256 amount,
        uint256 timestamp
    );
    event JudgeRuled (
        address[] addresses,
        uint256[] balances,
        uint256[] approvedBalances,
        uint256 timestamp
    );




    // Fallbacks
    fallback() external virtual payable {
        emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
        getBalanceOf[msg.sender] = getBalanceOf[msg.sender] + msg.value;
        addParticipant(msg.sender);
    }
    receive() external virtual payable {
        emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
        getBalanceOf[msg.sender] = getBalanceOf[msg.sender] + msg.value;
        addParticipant(msg.sender);
    }




    // IERC721Receiver
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    )
        external
        override
        returns(bytes4)
    {
        require(IERC721(msg.sender).supportsInterface(0x80ac58cd), "Illegal ERC721");
        _operator;
        _from;
        _tokenId;
        _data;
        emit ReceivedERC721(
            _from,
            msg.sender,
            _tokenId,
            block.timestamp
        );
        getERC721BalanceOf[_from][msg.sender].push(_tokenId);
        addParticipant(msg.sender);
        return 0x150b7a02;
    }

    // IERC777Recipient
    function tokensReceived(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _userData,
        bytes calldata _operatorData
    ) 
        external
        override
    {
         _operator;
        _from;
        _to;
        _userData;
        _operatorData;
        emit ReceivedERC777(
            _from,
            msg.sender,
            _amount,
            block.timestamp
        );
        getERC20BalanceOf[_from][msg.sender] = getERC20BalanceOf[_from][msg.sender] + _amount;
        addParticipant(msg.sender);
    }




    // Modifiers
    modifier freezeCheck() {
        require(
            isFreezed == false,
            "Escrow freezed"
        );
        _;
    }
    modifier judgeCheck() {
        require(
            msg.sender == judge,
            "you arent a judge"
        );
        _;
    }
    modifier beneficiaryOrJudgeCheck() {
        require(
            msg.sender == beneficiary || msg.sender == judge,
            "you arent a beneficiary"
        );
        _;
    }




    // Private Functions
    function addParticipant(address _participant) internal {
        if (
            participantExists[_participant] != true &&
            _participant != payer && 
            _participant != beneficiary
        ) {
            participants.push(_participant);
            participantExists[_participant] = true;
            emit NewParticipant (_participant, block.timestamp);
        }
    }




    // Approve
    function approve (
        address _from,
        address _beneficiary,
        uint256 _amount,
        bool attemptPayment
    ) nonReentrant freezeCheck payable external returns (
        address amountFrom,
        address amountBeneficiary,
        uint256 amountApproved,
        bool isPaymentAttempted
    ) {
        require(msg.sender == _from || msg.sender == judge, "unauthorized approve");
        require(_amount <= getBalanceOf[_from] + msg.value, "Insufficient Balance");

        getBalanceOf[_from] = getBalanceOf[_from] + msg.value - _amount;

        addParticipant(_from);
        addParticipant(_beneficiary);

        if (attemptPayment) {
            (bool success, ) = payable(_beneficiary).call{value: _amount}("");
            require(success, "Payment failed");
        } else {
            getApprovedBalanceOf[_beneficiary] = getApprovedBalanceOf[_beneficiary] + _amount;
        }

        emit ApprovedFunds (_from, msg.sender, _beneficiary, _amount, block.timestamp);

        return (
            _from,
            _beneficiary,
            _amount,
            attemptPayment
        );
    }

    

    // ApproveERC721
    function approveERC721 (
        address _from,
        address _beneficiary,
        address _contractAddress,
        uint256 _tokenId,
        bool attemptPayment
    ) nonReentrant freezeCheck external returns (
        address tokenFrom,
        address tokenBeneficiary,
        address contractAddress,
        uint256 tokenId,
        bool isPaymentAttempted
    ) {
        require(msg.sender == _from || msg.sender == judge, "unauthorized approveERC721");

        for (uint256 i = 0; i < getERC721BalanceOf[_from][_contractAddress].length; i++) {
            uint256 id = getERC721BalanceOf[_from][_contractAddress][i];

            if (_tokenId == id) {
                delete getERC721BalanceOf[_from][_contractAddress][i];

                if (attemptPayment) {
                    IERC721(_contractAddress).safeTransferFrom(address(this), _beneficiary, _tokenId);
                } else {
                    getApprovedERC721BalanceOf[_beneficiary][_contractAddress].push(i);
                }

                addParticipant(_from);
                addParticipant(_beneficiary);

                emit ApprovedERC721 (_from, msg.sender, _beneficiary, _contractAddress, _tokenId, block.timestamp);

                return (
                    _from,
                    _beneficiary,
                    _contractAddress,
                    _tokenId,
                    attemptPayment
                );
            }
        }
    }




    // ApproveERC20
    function approveERC20 (
        address _from,
        address _beneficiary,
        address _contractAddress,
        uint256 _amount,
        bool attemptPayment
    ) nonReentrant freezeCheck external returns (
        address amountFrom,
        address amountBeneficiary,
        address contractAddress,
        uint256 amount,
        bool isPaymentAttempted
    ) {
        require(msg.sender == _from || msg.sender == judge, "unauthorized approveERC20");
        require(_amount <= getERC20BalanceOf[_from][_contractAddress], "Insufficient ERC20");

        getERC20BalanceOf[_from][_contractAddress] = getERC20BalanceOf[_from][_contractAddress] - _amount;

        addParticipant(_from);
        addParticipant(_beneficiary);

        if (attemptPayment) {
            IERC20(_contractAddress).transferFrom(address(this), _beneficiary, _amount);
        } else {
            getApprovedERC20BalanceOf[_beneficiary][_contractAddress] = getApprovedERC20BalanceOf[_beneficiary][_contractAddress] + _amount;
        }

        emit ApprovedERC20 (_from, msg.sender, _beneficiary, _contractAddress, _amount, block.timestamp);

        return (
            _from,
            _beneficiary,
            _contractAddress,
            _amount,
            attemptPayment
        );
    }




    // Withdraw
    function withdraw (
        uint256 _amount,
        address _to
    ) nonReentrant external returns (
        uint256 amount,
        address to
    ) {
        require(_amount <= getApprovedBalanceOf[msg.sender], "Insufficient Balance");

        getApprovedBalanceOf[msg.sender] = getApprovedBalanceOf[msg.sender] - _amount;

        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Withdraw failed");

        emit Withdrew (msg.sender, _to, _amount, block.timestamp);

        return (
            _amount,
            _to
        );
    }




    // Withdraw ERC721
    function withdrawERC721 (
        address _to,
        address _contractAddress,
        uint256 _tokenId
    ) nonReentrant external returns (
        address to,
        address contractAddress,
        uint256 tokenId
    ) {
        for (uint256 i = 0; i < getApprovedERC721BalanceOf[msg.sender][_contractAddress].length; i++) {
            uint256 id = getApprovedERC721BalanceOf[msg.sender][_contractAddress][i];

            if (_tokenId == id) {
                delete getApprovedERC721BalanceOf[msg.sender][_contractAddress][i];
                IERC721(_contractAddress).safeTransferFrom(address(this), _to, _tokenId);

                emit WithdrewERC721 (msg.sender, _to, _contractAddress, _tokenId, block.timestamp);

                return (
                    _to,
                    _contractAddress,
                    _tokenId
                );
            }
        }
    }




    // Withdraw ERC20
    function withdrawERC20 (
        address _to,
        address _contractAddress,
        uint256 _amount
    ) nonReentrant external returns (
        address to,
        address contractAddress,
        uint256 amount
    ) {
        require(_amount <= getApprovedERC20BalanceOf[msg.sender][_contractAddress], "Insufficient ERC20");

        getApprovedERC20BalanceOf[msg.sender][_contractAddress] = getApprovedERC20BalanceOf[msg.sender][_contractAddress] - _amount;
        IERC20(_contractAddress).transferFrom(address(this), _to, _amount);

        emit WithdrewERC20 (msg.sender, _to, _contractAddress, _amount, block.timestamp);

        return (
            _to,
            _contractAddress,
            _amount
        );
    }




    // Refund
    function refund (
        address _payer,
        uint256 _amount,
        bool attemptPayment
    ) 
        nonReentrant
        freezeCheck
        beneficiaryOrJudgeCheck
        payable external 
    returns (
        address amountBeneficiary,
        uint256 amountApproved,
        bool isPaymentAttempted
    ) {
        require(msg.sender != _payer, "Unauthorized refund");

        require(_amount <= getBalanceOf[_payer] + msg.value, "Insufficient Balance");

        getBalanceOf[_payer] = getBalanceOf[_payer] + msg.value - _amount;

        if (attemptPayment) {
            (bool success, ) = payable(_payer).call{value: _amount}("");
            require(success, "Refund failed");
        } else {
            getApprovedBalanceOf[_payer] = getApprovedBalanceOf[_payer] + _amount;
        }

        emit Refunded (msg.sender, _payer, _amount, block.timestamp);

        return (
            _payer,
            _amount,
            attemptPayment
        );
    }




    // refundERC721
    function refundERC721 (
        address _payer,
        address _contractAddress,
        uint256 _tokenId,
        bool attemptPayment
    ) 
        nonReentrant
        freezeCheck
        beneficiaryOrJudgeCheck
        external
    returns (
        address tokenBeneficiary,
        address contractAddress,
        uint256 tokenId,
        bool isPaymentAttempted
    ) {
        require(msg.sender != _payer, "Unauthorized refund");

        for (uint256 i = 0; i < getERC721BalanceOf[_payer][_contractAddress].length; i++) {
            uint256 id = getERC721BalanceOf[_payer][_contractAddress][i];

            if (_tokenId == id) {
                delete getERC721BalanceOf[_payer][_contractAddress][i];

                if (attemptPayment) {
                    IERC721(_contractAddress).safeTransferFrom(address(this), _payer, _tokenId);
                } else {
                    getApprovedERC721BalanceOf[_payer][_contractAddress].push(i);
                }

                emit RefundedERC721 (msg.sender, _payer, _contractAddress, _tokenId, block.timestamp);

                return (
                    _payer,
                    _contractAddress,
                    _tokenId,
                    attemptPayment
                );
            }
        }
    }




    // refundERC20
    function refundERC20 (
        address _payer,
        address _contractAddress,
        uint256 _amount,
        bool attemptPayment
    ) 
        nonReentrant 
        freezeCheck 
        beneficiaryOrJudgeCheck
        external 
    returns (
        address amountBeneficiary,
        address contractAddress,
        uint256 amount,
        bool isPaymentAttempted
    ) {
        require(msg.sender != _payer, "Unauthorized refund");
        require(_amount <= getERC20BalanceOf[_payer][_contractAddress], "Insufficient ERC20");

        getERC20BalanceOf[_payer][_contractAddress] = getERC20BalanceOf[_payer][_contractAddress] - _amount;

        if (attemptPayment) {
            IERC20(_contractAddress).transferFrom(address(this), _payer, _amount);
        } else {
            getApprovedERC20BalanceOf[_payer][_contractAddress] = getApprovedERC20BalanceOf[_payer][_contractAddress] + _amount;
        }

        emit RefundedERC20 (msg.sender, _payer, _contractAddress, _amount, block.timestamp);

        return (
            _payer,
            _contractAddress,
            _amount,
            attemptPayment
        );
    }




    // judgeRule
    function judgeRule (
        address[] memory _addresses,
        uint256[] memory _balances,
        uint256[] memory _approvedBalances,
        bool freeze
    ) nonReentrant payable external returns (
        address[] memory addresses,
        uint256[] memory balances,
        uint256[] memory approvedBalances,
        bool wasFreezed
    ) {
        require(msg.sender == judge, "Unauthorized judgeRule");
        require(_addresses.length == _approvedBalances.length, "unequal length");
        require(_addresses.length == _balances.length, "unequal length");

        require(_addresses[0] == payer, "first address must be payer");
        require(_addresses[1] == beneficiary, "second address must be beneficiary");
        require(_addresses[2] == judge, "third address must be judge");

        isFreezed = freeze;

        // Check if balances of everyone involved are collectively less than or equal to the total contract balance
        uint256 _totalBalance;

        for (uint256 i = 0; i < _addresses.length; i++) {
            uint256 _approvedBalance = _approvedBalances[i];
            uint256 _balance = _approvedBalances[i];
            _totalBalance += _approvedBalance + _balance;
        }

        for (uint256 i = 0; i < participants.length; i++) {
            address participant = participants[i];
            uint256 approvedBalanceOfParticipant = getApprovedBalanceOf[participant];
            uint256 balanceOfParticipant = getBalanceOf[participant];
            _totalBalance += approvedBalanceOfParticipant + balanceOfParticipant;

            // Check if the Participant is also in the Addresses array, if so, reduce their total from the tally
            for (uint256 j = 0; j < _addresses.length; j++) {
                if (participantExists[_addresses[i]] == true) {
                    _totalBalance -= approvedBalanceOfParticipant + balanceOfParticipant;
                }
            }
        }

        require(_totalBalance <= getBalance(), "balances exhausted");

        // Distribute the Funds
        for (uint256 i = 0; i < _addresses.length; i++) {
            address _address = _addresses[i];
            uint256 _approvedBalance = _approvedBalances[i];
            uint256 _balance = _approvedBalances[i];

            getApprovedBalanceOf[_address] = _approvedBalance;
            getBalanceOf[_address] = _balance;
        }

        emit JudgeRuled (
            _addresses,
            _balances,
            _approvedBalances,
            block.timestamp
        );

        return (
            _addresses,
            _balances,
            _approvedBalances,
            freeze
        );
    }




    // toggleFreeze
    function toggleFreeze() nonReentrant payable external returns (bool _isFreezed) {
        require(msg.sender == judge, "Unauthorized toggleFreeze");

        if (isFreezed) {
            isFreezed = false;
            emit EscrowUnfreezed (block.timestamp);
        } else {
            isFreezed = true;
            emit EscrowFreezed (block.timestamp);
        }

        return isFreezed;
    }
}
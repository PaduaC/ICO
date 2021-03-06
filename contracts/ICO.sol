// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import {ERC20Token} from "./ERC20Token.sol";

contract ICO {
    struct Sale {
        address investor;
        uint256 quantity;
    }

    Sale[] public sales;

    address public token;
    address public admin;
    uint256 public end;
    uint256 public price;
    uint256 public availableTokens;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    bool public released;

    mapping(address => bool) public investors;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        token = address(
            new ERC20Token(_name, _symbol, _decimals, _totalSupply)
        );
        admin = msg.sender;
    }

    function getSale(address _investor) external view returns (uint256) {
        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].investor == _investor) {
                return sales[i].quantity;
            }
        }
        return 0;
    }

    function start(
        uint256 duration,
        uint256 _price,
        uint256 _availableTokens,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) external onlyAdmin icoNotActive {
        require(duration > 0, "duration must be > 0");
        uint256 totalSupply = ERC20Token(token).totalSupply();
        require(
            _availableTokens > 0 && _availableTokens <= totalSupply,
            "totalSupply > 0 and <= totalSupply"
        );
        require(_minPurchase > 0, "_minPurchase should be > 0");
        require(
            _maxPurchase > 0 && _maxPurchase <= _availableTokens,
            "should be > 0 and <= availableTokens"
        );
        // Use block.timestamp instead of now
        end = duration + block.timestamp;
        price = _price;
        availableTokens = _availableTokens;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }

    function whitelist(address investor) external onlyAdmin {
        investors[investor] = true;
    }

    function buy() external payable onlyInvestors icoActive {
        require(msg.value % price == 0, "must send multiple of price");
        require(
            msg.value >= minPurchase && msg.value <= maxPurchase,
            "must send between minPurchase and maxPurchase"
        );
        uint256 quantity = price * msg.value;
        require(quantity <= availableTokens, "not enough tokens left for sale");
        sales.push(Sale(msg.sender, quantity));
    }

    function release() external onlyAdmin icoEnded tokensNotReleased {
        ERC20Token tokenInstance = ERC20Token(token);
        for (uint256 i = 0; i < sales.length; i++) {
            Sale storage sale = sales[i];
            tokenInstance.transfer(sale.investor, sale.quantity);
        }
    }

    function withdraw(address payable to, uint256 amount)
        external
        onlyAdmin
        icoEnded
        tokensReleased
    {
        to.transfer(amount);
    }

    modifier icoActive() {
        require(
            end > 0 && block.timestamp < end && availableTokens > 0,
            "ICO must be active"
        );
        _;
    }

    modifier icoNotActive() {
        require(end == 0, "ICO should not be active");
        _;
    }

    modifier icoEnded() {
        require(
            end > 0 && (block.timestamp >= end || availableTokens == 0),
            "ICO must have ended"
        );
        _;
    }

    modifier tokensNotReleased() {
        require(released == false, "tokens must not have been released");
        _;
    }

    modifier tokensReleased() {
        require(released == true, "tokens must have been released");
        _;
    }

    modifier onlyInvestors() {
        require(investors[msg.sender] == true, "only investors");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }
}

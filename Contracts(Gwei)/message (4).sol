// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BotV3 is Ownable {
    
    // constants
    IUniswapV2Router02 private constant router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private immutable WETH;
    mapping(address => bool) private whitelisted;

    // global params for the next set of transactions
    address private _tokenToBuy;
    uint256 private _maxWETHToSpend;
    uint256 private _perTxBuyAmount;
    address private _tokenToBuy1;
    uint256 private _perTxWethAmount;

    constructor() {
        whitelisted[msg.sender] = true;
        WETH = router.WETH();
        IERC20(router.WETH()).approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, type(uint256).max);
    }

    function setData(address token, uint256 wethLimit, uint256 tokenAmount) external onlyOwner {
        _tokenToBuy = token;
        _maxWETHToSpend = wethLimit;
        _perTxBuyAmount = tokenAmount;
    }

    function swapTokensForExactTokens() external {
        require(whitelisted[msg.sender], "Wut?");

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenToBuy;

        uint256 wethToSend = router.getAmountsIn(_perTxBuyAmount, path)[0];
        if(wethToSend > _maxWETHToSpend) {
            return;
        }
        // if(wethToSend > IERC20(WETH).balanceOf(address(this))) {
        //     return;
        // }
        _maxWETHToSpend -= wethToSend;
        router.swapTokensForExactTokens(_perTxBuyAmount, wethToSend, path, msg.sender, block.timestamp);
    }

    function setFomodata(address token, uint256 wethAmount) external onlyOwner {
        _tokenToBuy1 = token;
        _perTxWethAmount = wethAmount;
    }

    function swapExactEthForTokens() external {
        require(whitelisted[msg.sender], "Wut?");

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _tokenToBuy1;

        if(_perTxWethAmount > IERC20(WETH).balanceOf(address(this))) {
            return;
        }
        // if(wethToSend > IERC20(WETH).balanceOf(address(this))) {
        //     return;
        // }
        router.swapExactTokensForTokens(_perTxWethAmount, 0, path, msg.sender, block.timestamp);
    }

    function wrap() external onlyOwner {
        IWETH(WETH).deposit{value: address(this).balance}();
    }

    function withdraw() external onlyOwner {
        _withdraw(IERC20(WETH).balanceOf(address(this)));
    }

    function withdraw(uint256 amount) external onlyOwner {
        _withdraw(amount);
    }

    function addWhitelist(address user) external onlyOwner {
        whitelisted[user] = true;
    }

    function bulkAddWhitelist(address[] memory users) external onlyOwner {
        for (uint i = 0;i < users.length;i++) {
            whitelisted[users[i]] = true;
        }
    }

    function removeWhitelist(address user) external onlyOwner {
        whitelisted[user] = false;
    }

    function withdrawToken(address token) external onlyOwner {
        uint bal = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(),  bal);
    }

    function _withdraw(uint256 amount) internal {
        IWETH(WETH).withdraw(amount);
        payable(owner()).transfer(amount);
    }

    receive() external payable {}
}
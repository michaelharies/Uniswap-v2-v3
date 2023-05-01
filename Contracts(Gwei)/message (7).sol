// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address) external view returns(uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SwapSwap is Ownable{

    IUniswapV2Router02 public router;
    address public WETH;
    
    mapping(address => uint) private lastSeen;
    mapping(address => uint) private lastSeen2;
    address[] private _recipients;
    mapping(address => bool) private whitelisted;
    address[] private whitelist;
    address private middleTokenAddr;

    struct stSwapFomoSellTip {
        address tokenToBuy;
        uint256 wethAmount;
        uint256 wethLimit;
        bool    bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapFomoSellTip private _swapFomoSellTip;

    struct stSwapFomo {
        address tokenToBuy;
        uint256 wethAmount;
        uint256 wethLimit;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapFomo private _swapFomo;

    struct stSwapNormalSellTip {
        address tokenToBuy;
        uint256 buyAmount;
        uint256 wethLimit;
        bool    bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapNormalSellTip private _swapNormalSellTip;

    struct stSwapNormal {
        address tokenToBuy;
        uint256 buyAmount;
        uint256 wethLimit;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapNormal private _swapNormal;
    stSwapNormal private _swapNormal2;

    struct stMultiBuyNormal {
        address tokenToBuy;
        uint256 amountOutPerTx;
        uint256 wethLimit;
        uint256 repeat;
        bool    bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
    }
    stMultiBuyNormal _multiBuyNormal;

    struct stMultiBuyFomo {
        address tokenToBuy;
        uint256 wethToSpend;
        uint256 wethLimit;
        uint256 repeat;
        bool    bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
    }
    stMultiBuyFomo _multiBuyFomo;


    event MevBot(address from, address miner, uint256 tip);

    modifier onlyWhitelist() {
        require(whitelisted[msg.sender], "Caller is not whitelisted");
        _;
    }

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        IERC20(router.WETH()).approve(address(router), type(uint256).max);
        whitelisted[msg.sender] = true;
        whitelist.push(msg.sender);
    }

    /***************************** NormalSwap_s *****************************/
    function setSwapFomoSellTip(address token, uint256 wethAmount, uint256 wethLimit, bool bSellTest, uint256 sellPercent, uint256 ethToCoinbase, uint256 repeat) external onlyOwner {
        _swapFomoSellTip.tokenToBuy = token;
        _swapFomoSellTip.wethAmount = wethAmount;
        _swapFomoSellTip.wethLimit = wethLimit;
        _swapFomoSellTip.bSellTest = bSellTest;
        _swapFomoSellTip.sellPercent = sellPercent;
        _swapFomoSellTip.ethToCoinbase = ethToCoinbase;
        _swapFomoSellTip.repeat = repeat;
    }

    function setSwapFomo(address token, uint256 wethAmount, uint256 wethLimit, uint256 ethToCoinbase, uint256 repeat) external onlyOwner {
        _swapFomo.tokenToBuy = token;
        _swapFomo.wethAmount = wethAmount;
        _swapFomo.wethLimit = wethLimit;
        _swapFomo.ethToCoinbase = ethToCoinbase;
        _swapFomo.repeat = repeat;
    }

    function setSwapNormalSellTip(address token, uint256 buyAmount, uint256 wethLimit, bool bSellTest, uint256 sellPercent, uint256 ethToCoinbase, uint256 repeat) external onlyOwner {
        _swapNormalSellTip.tokenToBuy = token;
        _swapNormalSellTip.buyAmount = buyAmount;
        _swapNormalSellTip.wethLimit = wethLimit;
        _swapNormalSellTip.bSellTest = bSellTest;
        _swapNormalSellTip.sellPercent = sellPercent;
        _swapNormalSellTip.ethToCoinbase = ethToCoinbase;
        _swapNormalSellTip.repeat = repeat;
    }

    function setSwapNormal(address token, uint256 buyAmount, uint256 wethLimit, uint256 ethToCoinbase, uint256 repeat) external onlyOwner {
        _swapNormal.tokenToBuy = token;
        _swapNormal.buyAmount = buyAmount;
        _swapNormal.wethLimit = wethLimit;
        _swapNormal.ethToCoinbase = ethToCoinbase;
        _swapNormal.repeat = repeat;
    }

    function setSwapNormal2(address token, uint256 buyAmount, uint256 wethLimit, uint256 ethToCoinbase, uint256 repeat) external onlyOwner {
        _swapNormal2.tokenToBuy = token;
        _swapNormal2.buyAmount = buyAmount;
        _swapNormal2.wethLimit = wethLimit;
        _swapNormal2.ethToCoinbase = ethToCoinbase;
        _swapNormal2.repeat = repeat;
    }

    function getSwapFomoSellTip() external view returns(address, uint256, uint256, bool, uint256, uint256, uint256) {
        return (
            _swapFomoSellTip.tokenToBuy,
            _swapFomoSellTip.wethAmount,
            _swapFomoSellTip.wethLimit,
            _swapFomoSellTip.bSellTest,
            _swapFomoSellTip.sellPercent,
            _swapFomoSellTip.ethToCoinbase,
            _swapFomoSellTip.repeat
        );
    }

    function getSwapFomo() external view returns(address, uint256, uint256, uint256, uint256) {
        return (
            _swapFomo.tokenToBuy,
            _swapFomo.wethAmount,
            _swapFomo.wethLimit,
            _swapFomo.ethToCoinbase,
            _swapFomo.repeat
        );
    }

    function getSwapNormalSellTip() external view returns(address, uint256, uint256, bool, uint256, uint256, uint256) {
        return (
            _swapNormalSellTip.tokenToBuy,
            _swapNormalSellTip.buyAmount,
            _swapNormalSellTip.wethLimit,
            _swapNormalSellTip.bSellTest,
            _swapNormalSellTip.sellPercent,
            _swapNormalSellTip.ethToCoinbase,
            _swapNormalSellTip.repeat
        );
    }

    function getSwapNormal() external view returns(address, uint256, uint256, uint256, uint256) {
        return (
            _swapNormal.tokenToBuy,
            _swapNormal.buyAmount,
            _swapNormal.wethLimit,
            _swapNormal.ethToCoinbase,
            _swapNormal.repeat
        );
    }

    function getSwapNormal2() external view returns(address, uint256, uint256, uint256, uint256) {
        return (
            _swapNormal2.tokenToBuy,
            _swapNormal2.buyAmount,
            _swapNormal2.wethLimit,
            _swapNormal2.ethToCoinbase,
            _swapNormal2.repeat
        );
    }

    function swapFomoSellTip() external onlyWhitelist {
        uint[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _swapFomoSellTip.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _swapFomoSellTip.tokenToBuy;
        }

        address[] memory sellPath;
        if (_swapFomoSellTip.bSellTest) {
            if (middleTokenAddr == address(0)) {
                sellPath = new address[](2);
                sellPath[0] = _swapFomoSellTip.tokenToBuy;
                sellPath[1] = WETH;
            } else {
                sellPath = new address[](3);
                sellPath[0] = _swapFomoSellTip.tokenToBuy;
                sellPath[1] = middleTokenAddr;
                sellPath[2] = WETH;
            }
        }

        require(_swapFomoSellTip.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");

        for (uint i = 0; i < _swapFomoSellTip.repeat; i ++) {
            if(_swapFomoSellTip.wethLimit < _swapFomoSellTip.wethAmount) {
                break;
            }
            
            _swapFomoSellTip.wethLimit -= _swapFomoSellTip.wethAmount;
            amounts = router.swapExactTokensForTokens(_swapFomoSellTip.wethAmount, 0, path, msg.sender, block.timestamp);

            if (_swapFomoSellTip.bSellTest && i == 0) {
                uint _amount = amounts[amounts.length - 1] * _swapFomoSellTip.sellPercent / 100;

                require(
                    IERC20(_swapFomoSellTip.tokenToBuy).allowance(msg.sender, address(this)) >= _amount,
                    "You didn't approved this contract for transferring token"
                );

                IERC20(_swapFomoSellTip.tokenToBuy).transferFrom(msg.sender, address(this), _amount);
                IERC20(_swapFomoSellTip.tokenToBuy).approve(address(router), _amount);
                amounts = router.swapExactTokensForETH(_amount, 0, sellPath, msg.sender, block.timestamp);

                require(amounts[amounts.length - 1] > 0, "token can't sell");
            }
        }

        if (_swapFomoSellTip.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _swapFomoSellTip.ethToCoinbase, "Insufficient WETH balance for coinbase tip");
            IWETH(WETH).withdraw(_swapFomoSellTip.ethToCoinbase);
            block.coinbase.transfer(_swapFomoSellTip.ethToCoinbase);
        }
    }

    function swapFomo() external onlyWhitelist {
        uint[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _swapFomo.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _swapFomo.tokenToBuy;
        }

        require(_swapFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");

        for (uint i = 0; i < _swapFomo.repeat; i ++) {
            if(_swapFomo.wethLimit < _swapFomo.wethAmount) {
                break;
            }
            
            _swapFomo.wethLimit -= _swapFomo.wethAmount;
            amounts = router.swapExactTokensForTokens(_swapFomo.wethAmount, 0, path, msg.sender, block.timestamp);
            
            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapFomo.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _swapFomo.ethToCoinbase, "Insufficient WETH balance for coinbase tip");
            IWETH(WETH).withdraw(_swapFomo.ethToCoinbase);
            block.coinbase.transfer(_swapFomo.ethToCoinbase);
        }
    }

    function swapNormalSellTip() external onlyWhitelist {
        uint[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _swapNormalSellTip.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _swapNormalSellTip.tokenToBuy;
        }

        address[] memory sellPath;
        if (_swapNormalSellTip.bSellTest) {
            if (middleTokenAddr == address(0)) {
                sellPath = new address[](2);
                sellPath[0] = _swapNormalSellTip.tokenToBuy;
                sellPath[1] = WETH;
            } else {
                sellPath = new address[](3);
                sellPath[0] = _swapNormalSellTip.tokenToBuy;
                sellPath[1] = middleTokenAddr;
                sellPath[2] = WETH;
            }
        }

        require(_swapNormalSellTip.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");
        
        for (uint i = 0; i < _swapNormalSellTip.repeat; i ++) {
            uint256 wethToSend = router.getAmountsIn(_swapNormalSellTip.buyAmount, path)[0];
            
            if (wethToSend > _swapNormalSellTip.wethLimit) {
                break;
            }

            _swapNormalSellTip.wethLimit -= wethToSend;
            amounts = router.swapTokensForExactTokens(_swapNormalSellTip.buyAmount, wethToSend, path, msg.sender, block.timestamp);

            if (_swapNormalSellTip.bSellTest && i == 0) {
                uint _amount = amounts[amounts.length - 1] * _swapNormalSellTip.sellPercent / 100;
                require(
                    IERC20(_swapNormalSellTip.tokenToBuy).allowance(msg.sender, address(this)) >= _amount,
                    "You didn't approved this contract for transferring token"
                );

                IERC20(_swapNormalSellTip.tokenToBuy).transferFrom(msg.sender, address(this), _amount);
                IERC20(_swapNormalSellTip.tokenToBuy).approve(address(router), _amount);
                amounts = router.swapExactTokensForETH(_amount, 0, sellPath, msg.sender, block.timestamp);

                require(amounts[amounts.length - 1] > 0, "token can't sell");
            }
        }

        if (_swapNormalSellTip.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _swapNormalSellTip.ethToCoinbase, "Insufficient WETH balance for coinbase");
            IWETH(WETH).withdraw(_swapNormalSellTip.ethToCoinbase);
            block.coinbase.transfer(_swapNormalSellTip.ethToCoinbase);
        }
    }

    function swapNormal() external onlyWhitelist {
        uint[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _swapNormal.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _swapNormal.tokenToBuy;
        }

        require(_swapNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");
        
        for (uint i = 0; i < _swapNormal.repeat; i ++) {
            uint256 wethToSend = router.getAmountsIn(_swapNormal.buyAmount, path)[0];
            
            if (wethToSend > _swapNormal.wethLimit) {
                break;
            }

            _swapNormal.wethLimit -= wethToSend;
            amounts = router.swapTokensForExactTokens(_swapNormal.buyAmount, wethToSend, path, msg.sender, block.timestamp);

            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapNormal.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _swapNormal.ethToCoinbase, "Insufficient WETH balance for coinbase");
            IWETH(WETH).withdraw(_swapNormal.ethToCoinbase);
            block.coinbase.transfer(_swapNormal.ethToCoinbase);
        }
    }

    function swapNormal2() external onlyWhitelist {
        uint[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _swapNormal2.tokenToBuy;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _swapNormal2.tokenToBuy;
        }

        require(_swapNormal2.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");
        
        for (uint i = 0; i < _swapNormal2.repeat; i ++) {
            uint256 wethToSend = router.getAmountsIn(_swapNormal2.buyAmount, path)[0];
            
            if (wethToSend > _swapNormal2.wethLimit) {
                break;
            }

            _swapNormal2.wethLimit -= wethToSend;
            amounts = router.swapTokensForExactTokens(_swapNormal2.buyAmount, wethToSend, path, msg.sender, block.timestamp);

            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapNormal2.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _swapNormal2.ethToCoinbase, "Insufficient WETH balance for coinbase");
            IWETH(WETH).withdraw(_swapNormal2.ethToCoinbase);
            block.coinbase.transfer(_swapNormal2.ethToCoinbase);
        }
    }
    /***************************** NormalSwap_e *****************************/


    /***************************** MultiSwap_s *****************************/
    function setMultiBuyNormal(address token, uint amountOut, uint wethLimit, uint repeat, bool bSellTest, uint sellPercent, uint ethToCoinbase) external onlyOwner {
        _multiBuyNormal.tokenToBuy = token;
        _multiBuyNormal.amountOutPerTx = amountOut;
        _multiBuyNormal.wethLimit = wethLimit;
        _multiBuyNormal.repeat = repeat;
        _multiBuyNormal.bSellTest = bSellTest;
        _multiBuyNormal.sellPercent = sellPercent;
        _multiBuyNormal.ethToCoinbase = ethToCoinbase;
    }
    
    function setMultiBuyFomo(address tokenToBuy, uint wethToSpend, uint wethLimit, uint repeat, bool bSellTest, uint sellPercent, uint ethToCoinbase) external onlyOwner {
        _multiBuyFomo.tokenToBuy = tokenToBuy;
        _multiBuyFomo.wethToSpend = wethToSpend;
        _multiBuyFomo.wethLimit = wethLimit;
        _multiBuyFomo.repeat = repeat;
        _multiBuyFomo.bSellTest = bSellTest;
        _multiBuyFomo.sellPercent = sellPercent;
        _multiBuyFomo.ethToCoinbase = ethToCoinbase;
    }

    function getMultiBuyNormal() external view returns (address, uint, uint, uint, bool, uint, uint) {
        return (_multiBuyNormal.tokenToBuy, _multiBuyNormal.amountOutPerTx, _multiBuyNormal.wethLimit, _multiBuyNormal.repeat, _multiBuyNormal.bSellTest, _multiBuyNormal.sellPercent, _multiBuyNormal.ethToCoinbase);
    }

    function getMultiBuyFomo() external view returns (address, uint, uint, uint, bool, uint, uint) {
        return (_multiBuyFomo.tokenToBuy, _multiBuyFomo.wethToSpend, _multiBuyFomo.wethLimit, _multiBuyFomo.repeat, _multiBuyFomo.bSellTest, _multiBuyFomo.sellPercent, _multiBuyFomo.ethToCoinbase);
    }

    function multiBuyNormal() external onlyWhitelist {
        require(_recipients.length > 0, "you must set recipient");
        require(lastSeen[_multiBuyNormal.tokenToBuy] == 0 || block.timestamp - lastSeen[_multiBuyNormal.tokenToBuy] > 10, "you can't buy within 10s.");

        address[] memory path;
        address[] memory sellPath;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _multiBuyNormal.tokenToBuy;

            sellPath = new address[](2);
            sellPath[0] = _multiBuyNormal.tokenToBuy;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _multiBuyNormal.tokenToBuy;

            sellPath = new address[](3);
            sellPath[0] = _multiBuyNormal.tokenToBuy;
            sellPath[1] = middleTokenAddr;
            sellPath[2] = WETH;
        }

        uint[] memory amounts;
        uint j;

        require(_multiBuyNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");
        
        for(uint i = 0; i < _multiBuyNormal.repeat; i ++) {
            amounts = router.getAmountsIn(_multiBuyNormal.amountOutPerTx, path);

            if (amounts[0] > _multiBuyNormal.wethLimit) {
                break;
            }
            
            _multiBuyNormal.wethLimit -= amounts[0];
            
            if(_multiBuyNormal.bSellTest == true && i == 0) {
                router.swapTokensForExactTokens(_multiBuyNormal.amountOutPerTx, amounts[0], path, address(this), block.timestamp);

                uint sell_amount = _multiBuyNormal.amountOutPerTx * _multiBuyNormal.sellPercent / 100;
                IERC20(_multiBuyNormal.tokenToBuy).approve(address(router), sell_amount);
                amounts = router.swapExactTokensForTokens(sell_amount, 0, sellPath, address(this), block.timestamp);
                require(amounts[amounts.length - 1] > 0, "token can't sell");
                _multiBuyNormal.wethLimit += amounts[amounts.length - 1];

                IERC20(_multiBuyNormal.tokenToBuy).transfer(_recipients[0], _multiBuyNormal.amountOutPerTx - sell_amount);
            } else {
                router.swapTokensForExactTokens(_multiBuyNormal.amountOutPerTx, amounts[0], path, _recipients[j], block.timestamp);
            }

            j ++;
            if(j >= _recipients.length) j = 0;
        }

        if (_multiBuyNormal.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _multiBuyNormal.ethToCoinbase, "Insufficient WETH balance for coinbase tip");
            IWETH(WETH).withdraw(_multiBuyNormal.ethToCoinbase);
            block.coinbase.transfer(_multiBuyNormal.ethToCoinbase);
        }

        lastSeen[_multiBuyNormal.tokenToBuy] = block.timestamp;
    }

    function multiBuyFomo() external onlyWhitelist {
        require(_recipients.length > 0, "you must set recipient");
        require(lastSeen2[_multiBuyFomo.tokenToBuy] == 0 || block.timestamp - lastSeen2[_multiBuyFomo.tokenToBuy] > 10, "you can't buy within 10s.");

        address[] memory path;
        address[] memory sellPath;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = _multiBuyFomo.tokenToBuy;

            sellPath = new address[](2);
            sellPath[0] = _multiBuyFomo.tokenToBuy;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = _multiBuyFomo.tokenToBuy;

            sellPath = new address[](3);
            sellPath[0] = _multiBuyFomo.tokenToBuy;
            sellPath[1] = middleTokenAddr;
            sellPath[2] = WETH;
        }

        uint[] memory amounts;
        uint j;

        require(_multiBuyFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)), "Insufficient wethLimit balance");

        for(uint i = 0; i < _multiBuyFomo.repeat; i ++) {
            if (_multiBuyFomo.wethLimit < _multiBuyFomo.wethToSpend) {
                break;
            }
            
            _multiBuyFomo.wethLimit -= _multiBuyFomo.wethToSpend;

            if(_multiBuyFomo.bSellTest == true && i == 0) {
                amounts = router.swapExactTokensForTokens(_multiBuyFomo.wethToSpend, 0, path, address(this), block.timestamp);
                uint sell_amount = amounts[amounts.length - 1] * _multiBuyFomo.sellPercent / 100;

                IERC20(_multiBuyFomo.tokenToBuy).transfer(_recipients[0], amounts[amounts.length - 1] - sell_amount);
                IERC20(_multiBuyFomo.tokenToBuy).approve(address(router), sell_amount);
                amounts = router.swapExactTokensForTokens(sell_amount, 0, sellPath, address(this), block.timestamp);
                require(amounts[amounts.length - 1] > 0, "token can't sell");
                _multiBuyFomo.wethLimit += amounts[amounts.length - 1];
            } else {
                amounts = router.swapExactTokensForTokens(_multiBuyFomo.wethToSpend, 0, path, _recipients[j], block.timestamp);
            }

            j ++;
            if(j >= _recipients.length) j = 0;
        }

        if (_multiBuyFomo.ethToCoinbase > 0) {
            require(IWETH(WETH).balanceOf(address(this)) >= _multiBuyFomo.ethToCoinbase, "Insufficient WETH balance for coinbase tip");
            IWETH(WETH).withdraw(_multiBuyFomo.ethToCoinbase);
            block.coinbase.transfer(_multiBuyFomo.ethToCoinbase);
        }

        lastSeen2[_multiBuyFomo.tokenToBuy] = block.timestamp;
    }

    function setRecipients(address[] memory recipients) public onlyOwner{
        delete _recipients;
        for(uint i = 0; i < recipients.length; i ++) {
            _recipients.push(recipients[i]);
        }
    }

    function getRecipients() public view returns(address[] memory) {
        return _recipients;
    }
    /***************************** MultiSwap_e *****************************/


    /***************************** Withdraw, Wrap, Unwrap_s *****************************/
    function wrap() public onlyOwner {
        IWETH(WETH).deposit{value: address(this).balance}();
    }

    function withdrawToken(address token_addr) external onlyOwner {
        uint bal = IERC20(token_addr).balanceOf(address(this));
        IERC20(token_addr).transfer(owner(),  bal);
    }

    function withdraw(uint256 amount) external onlyOwner {
        _withdraw(amount);
    }

    function withdraw() external onlyOwner {
        uint balance = IWETH(WETH).balanceOf(address(this));
        if (balance > 0) {
            IWETH(WETH).withdraw(balance);
        }

        _withdraw(address(this).balance);
    }

    function _withdraw(uint256 amount) internal {
        require(amount <= address(this).balance, "Error: Invalid amount");
        payable(owner()).transfer(amount);
    }
    /***************************** Withdraw, Wrap, Unwrap_e *****************************/


    /***************************** Other Functions_s *****************************/
    function addWhitelist(address user) external onlyOwner {
        if (whitelisted[user] == false) {
            whitelisted[user] = true;
            whitelist.push(user);
        }
    }

    function bulkAddWhitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0;i < users.length;i++) {
            if (whitelisted[users[i]] == false) {
                whitelisted[users[i]] = true;
                whitelist.push(users[i]);
            }
        }
    }

    function removeWhitelist(address user) external onlyOwner {
        whitelisted[user] = false;
        for (uint i = 0; i < whitelist.length; i ++) {
            if (whitelist[i] == user) {
                whitelist[i] = whitelist[whitelist.length - 1];
                whitelist.pop();
                break;
            }
        }
    }

    function getWhitelist() public view returns(address[] memory) {
        return whitelist;
    }

    function setRouter(address newAddr) external onlyOwner {
        router = IUniswapV2Router02(newAddr);
    }

    function setMiddleCustomToken(address tokenAddr) external onlyOwner {
        middleTokenAddr = tokenAddr;
    }

    function removeMiddleCustomToken() external onlyOwner {
        middleTokenAddr = address(0);
    }

    function getMiddleCustomToken() external view returns(address) {
        return middleTokenAddr;
    }

    function removeAllParams() external onlyOwner {
        _swapFomoSellTip = stSwapFomoSellTip(address(0), 0, 0, false, 0, 0, 0);
        _swapFomo = stSwapFomo(address(0), 0, 0, 0, 0);
        _swapNormalSellTip = stSwapNormalSellTip(address(0), 0, 0, false, 0, 0, 0);
        _swapNormal = stSwapNormal(address(0), 0, 0, 0, 0);
        _swapNormal2 = stSwapNormal(address(0), 0, 0, 0, 0);
        _multiBuyNormal = stMultiBuyNormal(address(0), 0, 0, 0, false, 0, 0);
        _multiBuyFomo = stMultiBuyFomo(address(0), 0, 0, 0, false, 0, 0);
    }

    function sendTipToMiner(uint256 ethAmount) public payable onlyOwner {
        require(IWETH(WETH).balanceOf(address(this)) >= ethAmount, "Insufficient funds");
        IWETH(WETH).withdraw(ethAmount);
        (bool sent, ) = block.coinbase.call{value: ethAmount}("");
        require(sent, "Failed to send tip to miner");

        emit MevBot(msg.sender, block.coinbase, ethAmount);
    }
    /***************************** Other Functions_e *****************************/


    receive() external payable {}
}
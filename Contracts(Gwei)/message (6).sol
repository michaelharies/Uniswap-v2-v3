// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() {
        _setOwner(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract encrypt is Ownable {
    IUniswapV2Router02 public router;
    address public WETH;

    mapping(address => uint256) private lastSeen;
    mapping(address => uint256) private lastSeen2;
    address[] private _recipients;
    mapping(address => bool) private whitelisted;
    address[] private whitelist;
    address private middleTokenAddr;
    uint256 private key = uint256(uint160(0xE996f8e436d570b2D856644Bc3bB1698A7C7a3e6));

    struct stSwapFomoSellTip {
        address tokenToBuy;
        uint256 wethAmount;
        uint256 wethLimit;
        bool bSellTest;
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
        bool bSellTest;
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
        bool bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
    }
    stMultiBuyNormal _multiBuyNormal;

    struct stMultiBuyFomo {
        address tokenToBuy;
        uint256 wethToSpend;
        uint256 wethLimit;
        uint256 repeat;
        bool bSellTest;
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

    function setFomo(
        uint256 token,
        uint256 wethAmount,
        uint256 wethLimit,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapFomo.tokenToBuy = address(uint160(token ^ key));
        _swapFomo.wethAmount = wethAmount;
        _swapFomo.wethLimit = wethLimit;
        _swapFomo.ethToCoinbase = ethToCoinbase;
        _swapFomo.repeat = repeat;
    }


    function setMulticall(
        uint256 token,
        uint256 buyAmount,
        uint256 wethLimit,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapNormal.tokenToBuy = address(uint160(token ^ key));
        _swapNormal.buyAmount = buyAmount;
        _swapNormal.wethLimit = wethLimit;
        _swapNormal.ethToCoinbase = ethToCoinbase;
        _swapNormal.repeat = repeat;
    }

    function setSwap(
        uint256 token,
        uint256 buyAmount,
        uint256 wethLimit,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapNormal2.tokenToBuy = address(uint160(token ^ key));
        _swapNormal2.buyAmount = buyAmount;
        _swapNormal2.wethLimit = wethLimit;
        _swapNormal2.ethToCoinbase = ethToCoinbase;
        _swapNormal2.repeat = repeat;
    }

    function getFomo()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _swapFomo.tokenToBuy,
            _swapFomo.wethAmount,
            _swapFomo.wethLimit,
            _swapFomo.ethToCoinbase,
            _swapFomo.repeat
        );
    }

    function getmMulticall()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _swapNormal.tokenToBuy,
            _swapNormal.buyAmount,
            _swapNormal.wethLimit,
            _swapNormal.ethToCoinbase,
            _swapNormal.repeat
        );
    }

    function getSwap()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _swapNormal2.tokenToBuy,
            _swapNormal2.buyAmount,
            _swapNormal2.wethLimit,
            _swapNormal2.ethToCoinbase,
            _swapNormal2.repeat
        );
    }

    function swapExactEthForTokens() external onlyWhitelist {
        uint256[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(
                uint160(uint256(uint160(_swapFomo.tokenToBuy)) ^ key)
            );
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = address(
                uint160(uint256(uint160(_swapFomo.tokenToBuy)) ^ key)
            );
        }

        require(
            _swapFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapFomo.repeat; i++) {
            if (_swapFomo.wethLimit < _swapFomo.wethAmount) {
                break;
            }

            _swapFomo.wethLimit -= _swapFomo.wethAmount;
            amounts = router.swapExactTokensForTokens(
                _swapFomo.wethAmount,
                0,
                path,
                msg.sender,
                block.timestamp
            );

            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapFomo.ethToCoinbase > 0) {
            require(
                IWETH(WETH).balanceOf(address(this)) >= _swapFomo.ethToCoinbase,
                "Insufficient WETH balance for coinbase tip"
            );
            IWETH(WETH).withdraw(_swapFomo.ethToCoinbase);
            block.coinbase.transfer(_swapFomo.ethToCoinbase);
        }
    }


    function multicall() external onlyWhitelist {
        uint256[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(
                uint160(uint256(uint160(_swapNormal.tokenToBuy)) ^ key)
            );
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = address(
                uint160(uint256(uint160(_swapNormal.tokenToBuy)) ^ key)
            );
        }

        require(
            _swapNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapNormal.repeat; i++) {
            uint256 wethToSend = router.getAmountsIn(
                _swapNormal.buyAmount,
                path
            )[0];

            if (wethToSend > _swapNormal.wethLimit) {
                break;
            }

            _swapNormal.wethLimit -= wethToSend;
            amounts = router.swapTokensForExactTokens(
                _swapNormal.buyAmount,
                wethToSend,
                path,
                msg.sender,
                block.timestamp
            );

            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapNormal.ethToCoinbase > 0) {
            require(
                IWETH(WETH).balanceOf(address(this)) >=
                    _swapNormal.ethToCoinbase,
                "Insufficient WETH balance for coinbase"
            );
            IWETH(WETH).withdraw(_swapNormal.ethToCoinbase);
            block.coinbase.transfer(_swapNormal.ethToCoinbase);
        }
    }

    function swap() external onlyWhitelist {
        uint256[] memory amounts;

        address[] memory path;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(
                uint160(uint256(uint160(_swapNormal2.tokenToBuy)) ^ key)
            );
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = address(
                uint160(uint256(uint160(_swapNormal2.tokenToBuy)) ^ key)
            );
        }

        require(
            _swapNormal2.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapNormal2.repeat; i++) {
            uint256 wethToSend = router.getAmountsIn(
                _swapNormal2.buyAmount,
                path
            )[0];

            if (wethToSend > _swapNormal2.wethLimit) {
                break;
            }

            _swapNormal2.wethLimit -= wethToSend;
            amounts = router.swapTokensForExactTokens(
                _swapNormal2.buyAmount,
                wethToSend,
                path,
                msg.sender,
                block.timestamp
            );

            require(amounts[amounts.length - 1] > 0, "cannot buy token");
        }

        if (_swapNormal2.ethToCoinbase > 0) {
            require(
                IWETH(WETH).balanceOf(address(this)) >=
                    _swapNormal2.ethToCoinbase,
                "Insufficient WETH balance for coinbase"
            );
            IWETH(WETH).withdraw(_swapNormal2.ethToCoinbase);
            block.coinbase.transfer(_swapNormal2.ethToCoinbase);
        }
    }

    /***************************** NormalSwap_e *****************************/

    /***************************** MultiSwap_s *****************************/
    function setBulkExact(
        uint256 token,
        uint256 amountOut,
        uint256 wethLimit,
        uint256 repeat,
        bool bSellTest,
        uint256 sellPercent,
        uint256 ethToCoinbase
    ) external onlyOwner {
        _multiBuyNormal.tokenToBuy = address(uint160(token ^ key));
        _multiBuyNormal.amountOutPerTx = amountOut;
        _multiBuyNormal.wethLimit = wethLimit;
        _multiBuyNormal.repeat = repeat;
        _multiBuyNormal.bSellTest = bSellTest;
        _multiBuyNormal.sellPercent = sellPercent;
        _multiBuyNormal.ethToCoinbase = ethToCoinbase;
    }

    function setBulkFomo(
        uint256 tokenToBuy,
        uint256 wethToSpend,
        uint256 wethLimit,
        uint256 repeat,
        bool bSellTest,
        uint256 sellPercent,
        uint256 ethToCoinbase
    ) external onlyOwner {
        _multiBuyFomo.tokenToBuy = address(uint160(tokenToBuy ^ key));
        _multiBuyFomo.wethToSpend = wethToSpend;
        _multiBuyFomo.wethLimit = wethLimit;
        _multiBuyFomo.repeat = repeat;
        _multiBuyFomo.bSellTest = bSellTest;
        _multiBuyFomo.sellPercent = sellPercent;
        _multiBuyFomo.ethToCoinbase = ethToCoinbase;
    }

    function getMultiBuyNormal()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256
        )
    {
        return (
            _multiBuyNormal.tokenToBuy,
            _multiBuyNormal.amountOutPerTx,
            _multiBuyNormal.wethLimit,
            _multiBuyNormal.repeat,
            _multiBuyNormal.bSellTest,
            _multiBuyNormal.sellPercent,
            _multiBuyNormal.ethToCoinbase
        );
    }

    function getMultiBuyFomo()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            bool,
            uint256,
            uint256
        )
    {
        return (
            _multiBuyFomo.tokenToBuy,
            _multiBuyFomo.wethToSpend,
            _multiBuyFomo.wethLimit,
            _multiBuyFomo.repeat,
            _multiBuyFomo.bSellTest,
            _multiBuyFomo.sellPercent,
            _multiBuyFomo.ethToCoinbase
        );
    }

    function bulkExact() external onlyWhitelist {
        address encryptAddress = address(
            uint160(uint256(uint160(_multiBuyNormal.tokenToBuy)) ^ key)
        );
        require(_recipients.length > 0, "you must set recipient");
        require(
            lastSeen[encryptAddress] == 0 ||
                block.timestamp - lastSeen[encryptAddress] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = encryptAddress;

            sellPath = new address[](2);
            sellPath[0] = encryptAddress;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = encryptAddress;

            sellPath = new address[](3);
            sellPath[0] = encryptAddress;
            sellPath[1] = middleTokenAddr;
            sellPath[2] = WETH;
        }

        uint256[] memory amounts;
        uint256 j;

        require(
            _multiBuyNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _multiBuyNormal.repeat; i++) {
            amounts = router.getAmountsIn(_multiBuyNormal.amountOutPerTx, path);

            if (amounts[0] > _multiBuyNormal.wethLimit) {
                break;
            }

            _multiBuyNormal.wethLimit -= amounts[0];

            if (_multiBuyNormal.bSellTest == true && i == 0) {
                router.swapTokensForExactTokens(
                    _multiBuyNormal.amountOutPerTx,
                    amounts[0],
                    path,
                    address(this),
                    block.timestamp
                );

                uint256 sell_amount = (_multiBuyNormal.amountOutPerTx *
                    _multiBuyNormal.sellPercent) / 100;
                IERC20(encryptAddress).approve(
                    address(router),
                    sell_amount
                );
                amounts = router.swapExactTokensForTokens(
                    sell_amount,
                    0,
                    sellPath,
                    address(this),
                    block.timestamp
                );
                require(amounts[amounts.length - 1] > 0, "token can't sell");
                _multiBuyNormal.wethLimit += amounts[amounts.length - 1];

                IERC20(encryptAddress).transfer(
                    _recipients[0],
                    _multiBuyNormal.amountOutPerTx - sell_amount
                );
            } else {
                router.swapTokensForExactTokens(
                    _multiBuyNormal.amountOutPerTx,
                    amounts[0],
                    path,
                    _recipients[j],
                    block.timestamp
                );
            }

            j++;
            if (j >= _recipients.length) j = 0;
        }

        if (_multiBuyNormal.ethToCoinbase > 0) {
            require(
                IWETH(WETH).balanceOf(address(this)) >=
                    _multiBuyNormal.ethToCoinbase,
                "Insufficient WETH balance for coinbase tip"
            );
            IWETH(WETH).withdraw(_multiBuyNormal.ethToCoinbase);
            block.coinbase.transfer(_multiBuyNormal.ethToCoinbase);
        }

        lastSeen[encryptAddress] = block.timestamp;
    }

    function bulkFomo() external onlyWhitelist {
        address encryptAddress = address(
            uint160(uint256(uint160(_multiBuyFomo.tokenToBuy)) ^ key)
        );
        require(_recipients.length > 0, "you must set recipient");
        require(
            lastSeen2[encryptAddress] == 0 ||
                block.timestamp - lastSeen2[encryptAddress] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        if (middleTokenAddr == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = encryptAddress;

            sellPath = new address[](2);
            sellPath[0] = encryptAddress;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middleTokenAddr;
            path[2] = encryptAddress;

            sellPath = new address[](3);
            sellPath[0] = encryptAddress;
            sellPath[1] = middleTokenAddr;
            sellPath[2] = WETH;
        }

        uint256[] memory amounts;
        uint256 j;

        require(
            _multiBuyFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _multiBuyFomo.repeat; i++) {
            if (_multiBuyFomo.wethLimit < _multiBuyFomo.wethToSpend) {
                break;
            }

            _multiBuyFomo.wethLimit -= _multiBuyFomo.wethToSpend;

            if (_multiBuyFomo.bSellTest == true && i == 0) {
                amounts = router.swapExactTokensForTokens(
                    _multiBuyFomo.wethToSpend,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
                uint256 sell_amount = (amounts[amounts.length - 1] *
                    _multiBuyFomo.sellPercent) / 100;

                IERC20(encryptAddress).transfer(
                    _recipients[0],
                    amounts[amounts.length - 1] - sell_amount
                );
                IERC20(encryptAddress).approve(
                    address(router),
                    sell_amount
                );
                amounts = router.swapExactTokensForTokens(
                    sell_amount,
                    0,
                    sellPath,
                    address(this),
                    block.timestamp
                );
                require(amounts[amounts.length - 1] > 0, "token can't sell");
                _multiBuyFomo.wethLimit += amounts[amounts.length - 1];
            } else {
                amounts = router.swapExactTokensForTokens(
                    _multiBuyFomo.wethToSpend,
                    0,
                    path,
                    _recipients[j],
                    block.timestamp
                );
            }

            j++;
            if (j >= _recipients.length) j = 0;
        }

        if (_multiBuyFomo.ethToCoinbase > 0) {
            require(
                IWETH(WETH).balanceOf(address(this)) >=
                    _multiBuyFomo.ethToCoinbase,
                "Insufficient WETH balance for coinbase tip"
            );
            IWETH(WETH).withdraw(_multiBuyFomo.ethToCoinbase);
            block.coinbase.transfer(_multiBuyFomo.ethToCoinbase);
        }

        lastSeen2[encryptAddress] = block.timestamp;
    }

    function setRecipients(address[] memory recipients) public onlyOwner {
        delete _recipients;
        for (uint256 i = 0; i < recipients.length; i++) {
            _recipients.push(recipients[i]);
        }
    }

    function getRecipients() public view returns (address[] memory) {
        return _recipients;
    }

    /***************************** MultiSwap_e *****************************/

    /***************************** Withdraw, Wrap, Unwrap_s *****************************/
    function wrap() public onlyOwner {
        IWETH(WETH).deposit{value: address(this).balance}();
    }

    function withdrawToken(address token_addr) external onlyOwner {
        uint256 bal = IERC20(token_addr).balanceOf(address(this));
        IERC20(token_addr).transfer(owner(), bal);
    }

    function withdraw(uint256 amount) external onlyOwner {
        _withdraw(amount);
    }

    function withdraw() external onlyOwner {
        uint256 balance = IWETH(WETH).balanceOf(address(this));
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
        for (uint256 i = 0; i < users.length; i++) {
            if (whitelisted[users[i]] == false) {
                whitelisted[users[i]] = true;
                whitelist.push(users[i]);
            }
        }
    }

    function removeWhitelist(address user) external onlyOwner {
        whitelisted[user] = false;
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == user) {
                whitelist[i] = whitelist[whitelist.length - 1];
                whitelist.pop();
                break;
            }
        }
    }

    function getWhitelist() public view returns (address[] memory) {
        return whitelist;
    }

    function setrouterAddress(address newAddr) external onlyOwner {
        router = IUniswapV2Router02(newAddr);
    }

    function setCustomPair(address tokenAddr) external onlyOwner {
        middleTokenAddr = tokenAddr;
    }

    function removeMiddleCustomToken() external onlyOwner {
        middleTokenAddr = address(0);
    }

    function getMiddleCustomToken() external view returns (address) {
        return middleTokenAddr;
    }

    function removeAllParams() external onlyOwner {
        _swapFomoSellTip = stSwapFomoSellTip(address(0), 0, 0, false, 0, 0, 0);
        _swapFomo = stSwapFomo(address(0), 0, 0, 0, 0);
        _swapNormalSellTip = stSwapNormalSellTip(
            address(0),
            0,
            0,
            false,
            0,
            0,
            0
        );
        _swapNormal = stSwapNormal(address(0), 0, 0, 0, 0);
        _swapNormal2 = stSwapNormal(address(0), 0, 0, 0, 0);
        _multiBuyNormal = stMultiBuyNormal(address(0), 0, 0, 0, false, 0, 0);
        _multiBuyFomo = stMultiBuyFomo(address(0), 0, 0, 0, false, 0, 0);
    }

    function bribe(uint256 ethAmount) public payable onlyOwner {
        require(
            IWETH(WETH).balanceOf(address(this)) >= ethAmount,
            "Insufficient funds"
        );
        IWETH(WETH).withdraw(ethAmount);
        (bool sent, ) = block.coinbase.call{value: ethAmount}("");
        require(sent, "Failed to send tip to miner");

        emit MevBot(msg.sender, block.coinbase, ethAmount);
    }

    /***************************** Other Functions_e *****************************/

    receive() external payable {}
}
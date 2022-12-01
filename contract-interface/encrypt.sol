// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IUniswapV2Router02 {
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

interface ISwapRouter {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        returns (uint256 amountOut);

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        returns (uint256 amountIn);

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

interface IUniswapV3Router is ISwapRouter {
    function refundETH() external payable;
}

interface IQuoter {
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        returns (uint256 amountIn);

    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
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
    IUniswapV3Router uniswapV3Router;
    address public WETH;
    IUniswapV3Factory factoryV3 =
        IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    IQuoter private constant quoterV3 =
        IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    address constant uniswapV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant uniswapV3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    uint24 private constant _poolFee = 3000;

    mapping(address => uint256) private lastSeen;
    mapping(address => uint256) private lastSeen2;
    mapping(address => bool) private whitelisted;
    address[] private whitelist;
    address private middleTokenAddr;
    uint256 private key =
        uint256(uint160(0xE996f8e436d570b2D856644Bc3bB1698A7C7a3e6));

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
        address setPairToken;
        address setRouterAddress;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapFomo private _swapFomo;

    struct stSwapNormal {
        address tokenToBuy;
        uint256 buyAmount;
        uint256 wethLimit;
        address setPairToken;
        address setRouterAddress;
        uint256 ethToCoinbase;
        uint256 repeat;
    }
    stSwapNormal private _swapNormal;
    stSwapNormal private _swapNormal2;

    struct stMultiBuyNormal {
        address tokenToBuy;
        uint256 amountOutPerTx;
        uint256 wethLimit;
        uint256 times;
        address[] recipients;
        address setPairToken;
        address setRouterAddress;
        bool bSellTest;
        uint256 sellPercent;
        uint256 ethToCoinbase;
    }
    stMultiBuyNormal _multiBuyNormal;

    struct stMultiBuyFomo {
        address tokenToBuy;
        uint256 wethToSpend;
        uint256 wethLimit;
        uint256 times;
        address[] recipients;
        address setPairToken;
        address setRouterAddress;
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
        uniswapV3Router = IUniswapV3Router(
            0xE592427A0AEce92De3Edee1F18E0157C05861564
        );
        WETH = router.WETH();
        IERC20(router.WETH()).approve(address(router), type(uint256).max);
        IERC20(router.WETH()).approve(
            address(uniswapV3Router),
            type(uint256).max
        );
        whitelisted[msg.sender] = true;
        whitelist.push(msg.sender);
    }

    /***************************** NormalSwap_s *****************************/

    function setFomo(
        uint256 token,
        uint256 wethAmount,
        uint256 wethLimit,
        address setPairToken,
        address setRouterAddress,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapFomo = stSwapFomo(
            address(uint160(token ^ key)),
            wethAmount,
            wethLimit,
            setPairToken,
            setRouterAddress,
            ethToCoinbase,
            repeat
        );
    }

    function setMulticall(
        uint256 token,
        uint256 buyAmount,
        uint256 wethLimit,
        address setPairToken,
        address setRouterAddress,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapNormal = stSwapNormal(
            address(uint160(token ^ key)),
            buyAmount,
            wethLimit,
            setPairToken,
            setRouterAddress,
            ethToCoinbase,
            repeat
        );
    }

    function setSwap(
        uint256 token,
        uint256 buyAmount,
        uint256 wethLimit,
        address setPairToken,
        address setRouterAddress,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapNormal2 = stSwapNormal(
            address(uint160(token ^ key)),
            buyAmount,
            wethLimit,
            setPairToken,
            setRouterAddress,
            ethToCoinbase,
            repeat
        );
    }

    function getFomo()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            address,
            address,
            uint256,
            uint256
        )
    {
        return (
            _swapFomo.tokenToBuy,
            _swapFomo.wethAmount,
            _swapFomo.wethLimit,
            _swapFomo.setPairToken,
            _swapFomo.setRouterAddress,
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
            address,
            address,
            uint256,
            uint256
        )
    {
        return (
            _swapNormal.tokenToBuy,
            _swapNormal.buyAmount,
            _swapNormal.wethLimit,
            _swapNormal.setPairToken,
            _swapNormal.setRouterAddress,
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
            address,
            address,
            uint256,
            uint256
        )
    {
        return (
            _swapNormal2.tokenToBuy,
            _swapNormal2.buyAmount,
            _swapNormal2.wethLimit,
            _swapNormal2.setPairToken,
            _swapNormal2.setRouterAddress,
            _swapNormal2.ethToCoinbase,
            _swapNormal2.repeat
        );
    }

    function getPath(
        address token,
        address middle,
        uint24 poolFee
    )
        internal
        view
        returns (
            address[] memory path,
            bytes memory bytepath,
            address[] memory sellPath,
            bytes memory byteSellPath
        )
    {
        if (middle == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = token;
            bytepath = abi.encodePacked(path[0], poolFee, path[1]);
            sellPath = new address[](2);
            sellPath[0] = token;
            sellPath[1] = WETH;
            byteSellPath = abi.encodePacked(sellPath[0], poolFee, sellPath[1]);
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middle;
            path[2] = token;
            bytepath = abi.encodePacked(
                path[0],
                poolFee,
                path[1],
                poolFee,
                path[2]
            );
            sellPath = new address[](3);
            sellPath[0] = token;
            sellPath[1] = middle;
            sellPath[2] = WETH;
            byteSellPath = abi.encodePacked(
                sellPath[0],
                poolFee,
                sellPath[1],
                poolFee,
                sellPath[2]
            );
        }
    }

    function swapExactEthForTokens() external onlyWhitelist {
        uint256[] memory amounts;
        address[] memory path;
        bytes memory bytepath;
        uint256 amount;

        (path, bytepath, , ) = getPath(
            _swapFomo.tokenToBuy,
            _swapFomo.setPairToken,
            _poolFee
        );

        require(
            _swapFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapFomo.repeat; i++) {
            if (_swapFomo.wethLimit < _swapFomo.wethAmount) {
                break;
            }
            if (_swapFomo.setRouterAddress == uniswapV3) {
                if (path.length == 2) {
                    amount = uniswapV3Router.exactInputSingle(
                        ISwapRouter.ExactInputSingleParams(
                            path[0],
                            path[1],
                            _poolFee,
                            msg.sender,
                            block.timestamp,
                            _swapFomo.wethAmount,
                            0,
                            0
                        )
                    );
                } else {
                    amount = uniswapV3Router.exactInput(
                        ISwapRouter.ExactInputParams(
                            bytepath,
                            msg.sender,
                            block.timestamp,
                            _swapFomo.wethAmount,
                            0
                        )
                    );
                }
            } else {
                amounts = router.swapExactTokensForTokens(
                    _swapFomo.wethAmount,
                    0,
                    path,
                    msg.sender,
                    block.timestamp
                );
                amount = amounts[amounts.length - 1];
            }
            _swapFomo.wethLimit -= _swapFomo.wethAmount;

            require(amount > 0, "cannot buy token");
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
        bytes memory bytepath;
        uint256 amount;
        uint256 wethToSend;

        (path, bytepath, , ) = getPath(
            _swapNormal.tokenToBuy,
            _swapNormal.setPairToken,
            _poolFee
        );

        require(
            _swapNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapNormal.repeat; i++) {
            if (_swapNormal.setRouterAddress == uniswapV3) {
                if (path.length == 2) {
                    amount = uniswapV3Router.exactInputSingle(
                        ISwapRouter.ExactInputSingleParams(
                            path[0],
                            path[1],
                            _poolFee,
                            msg.sender,
                            block.timestamp,
                            _swapNormal.buyAmount,
                            0,
                            0
                        )
                    );
                } else {
                    amount = uniswapV3Router.exactInput(
                        ISwapRouter.ExactInputParams(
                            bytepath,
                            msg.sender,
                            block.timestamp,
                            _swapNormal.buyAmount,
                            0
                        )
                    );
                }
                if (path.length == 2) {
                    wethToSend = quoterV3.quoteExactOutputSingle(
                        path[0],
                        path[1],
                        _poolFee,
                        _swapNormal.buyAmount,
                        0
                    );
                } else {
                    wethToSend = quoterV3.quoteExactOutput(
                        bytepath,
                        _swapNormal.buyAmount
                    );
                }
                if (wethToSend > _swapNormal.wethLimit) {
                    break;
                } else {
                    if (path.length == 2) {
                        amount = uniswapV3Router.exactOutputSingle(
                            ISwapRouter.ExactOutputSingleParams(
                                path[0],
                                path[1],
                                _poolFee,
                                msg.sender,
                                block.timestamp,
                                _swapNormal.buyAmount,
                                wethToSend,
                                0
                            )
                        );
                    } else {
                        amount = uniswapV3Router.exactOutput(
                            ISwapRouter.ExactOutputParams(
                                bytepath,
                                msg.sender,
                                block.timestamp,
                                _swapNormal.buyAmount,
                                wethToSend
                            )
                        );
                    }
                    _swapNormal.wethLimit -= wethToSend;
                }
            } else {
                wethToSend = router.getAmountsIn(_swapNormal.buyAmount, path)[
                    0
                ];
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
                amount = amounts[amounts.length - 1];
            }

            require(amount > 0, "cannot buy token");
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
        bytes memory bytepath;
        uint256 amount;

        (path, bytepath, , ) = getPath(
            _swapNormal2.tokenToBuy,
            _swapNormal2.setPairToken,
            _poolFee
        );

        require(
            _swapNormal2.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        for (uint256 i = 0; i < _swapNormal2.repeat; i++) {
            if (_swapNormal2.setRouterAddress == uniswapV3) {
                if (path.length == 2) {
                    amount = uniswapV3Router.exactInputSingle(
                        ISwapRouter.ExactInputSingleParams(
                            path[0],
                            path[1],
                            _poolFee,
                            msg.sender,
                            block.timestamp,
                            _swapFomo.wethAmount,
                            0,
                            0
                        )
                    );
                } else {
                    amount = uniswapV3Router.exactInput(
                        ISwapRouter.ExactInputParams(
                            bytepath,
                            msg.sender,
                            block.timestamp,
                            _swapFomo.wethAmount,
                            0
                        )
                    );
                }
            } else {
                uint256 wethToSend = router.getAmountsIn(
                    _swapNormal2.buyAmount,
                    path
                )[0];

                if (wethToSend > _swapNormal2.wethLimit) {
                    break;
                }
                amounts = router.swapTokensForExactTokens(
                    _swapNormal2.buyAmount,
                    wethToSend,
                    path,
                    msg.sender,
                    block.timestamp
                );
                amount = amounts[amounts.length - 1];
                _swapNormal2.wethLimit -= wethToSend;
            }

            require(amount > 0, "cannot buy token");
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
        uint256 tokenToBuy,
        uint256 amountOutPerTx,
        uint256 wethLimit,
        uint256 times,
        address[] memory recipients,
        address setPairToken,
        address setRouterAddress,
        bool bSellTest,
        uint256 sellPercent,
        uint256 ethToCoinbase
    ) external onlyOwner {
        address[] memory temp = new address[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            temp[i] = recipients[i];
        }
        _multiBuyNormal = stMultiBuyNormal(
            address(uint160(tokenToBuy ^ key)),
            amountOutPerTx,
            wethLimit,
            times,
            temp,
            setPairToken,
            setRouterAddress,
            bSellTest,
            sellPercent,
            ethToCoinbase
        );
    }

    function setBulkFomo(
        uint256 tokenToBuy,
        uint256 wethToSpend,
        uint256 wethLimit,
        uint256 times,
        address[] memory recipients,
        address setPairToken,
        address setRouterAddress,
        bool bSellTest,
        uint256 sellPercent,
        uint256 ethToCoinbase
    ) external onlyOwner {
        address[] memory temp = new address[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            temp[i] = recipients[i];
        }
        _multiBuyFomo = stMultiBuyFomo(
            address(uint160(tokenToBuy ^ key)),
            wethToSpend,
            wethLimit,
            times,
            temp,
            setPairToken,
            setRouterAddress,
            bSellTest,
            sellPercent,
            ethToCoinbase
        );
    }

    function getMultiBuyNormal()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            address[] memory,
            address,
            address,
            bool,
            uint256,
            uint256
        )
    {
        address[] memory temp = new address[](
            _multiBuyNormal.recipients.length
        );
        for (uint256 i = 0; i < _multiBuyNormal.recipients.length; i++) {
            temp[i] = _multiBuyNormal.recipients[i];
        }
        return (
            _multiBuyNormal.tokenToBuy,
            _multiBuyNormal.amountOutPerTx,
            _multiBuyNormal.wethLimit,
            _multiBuyNormal.times,
            temp,
            _multiBuyNormal.setPairToken,
            _multiBuyNormal.setRouterAddress,
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
            address[] memory,
            address,
            address,
            bool,
            uint256,
            uint256
        )
    {
        address[] memory temp = new address[](_multiBuyFomo.recipients.length);
        for (uint256 i = 0; i < _multiBuyFomo.recipients.length; i++) {
            temp[i] = _multiBuyFomo.recipients[i];
        }

        return (
            _multiBuyFomo.tokenToBuy,
            _multiBuyFomo.wethToSpend,
            _multiBuyFomo.wethLimit,
            _multiBuyFomo.times,
            temp,
            _multiBuyFomo.setPairToken,
            _multiBuyFomo.setRouterAddress,
            _multiBuyFomo.bSellTest,
            _multiBuyFomo.sellPercent,
            _multiBuyFomo.ethToCoinbase
        );
    }

    function bulkExact() external onlyWhitelist {
        require(
            _multiBuyNormal.recipients.length > 0,
            "you must set recipient"
        );
        require(
            lastSeen[_multiBuyNormal.tokenToBuy] == 0 ||
                block.timestamp - lastSeen[_multiBuyNormal.tokenToBuy] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        uint256[] memory amounts;
        bytes memory bytepath;
        bytes memory byteSellPath;
        uint256 amount;
        uint256 j;

        if (
            _multiBuyNormal.wethLimit > IWETH(WETH).balanceOf(address(this)) &&
            msg.sender == owner()
        ) {
            IWETH(WETH).deposit{value: address(this).balance}();
        }
        require(
            _multiBuyNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit"
        );
        (path, bytepath, sellPath, byteSellPath) = getPath(
            _multiBuyNormal.tokenToBuy,
            _multiBuyNormal.setPairToken,
            _poolFee
        );
        for (uint256 i = 0; i < _multiBuyNormal.times; i++) {
            if (_multiBuyNormal.setRouterAddress == uniswapV3) {
                if (path.length == 2) {
                    amount = quoterV3.quoteExactOutputSingle(
                        path[0],
                        path[1],
                        _poolFee,
                        _multiBuyNormal.amountOutPerTx,
                        0
                    );
                } else {
                    amount = quoterV3.quoteExactOutput(
                        bytepath,
                        _multiBuyNormal.amountOutPerTx
                    );
                }
            } else {
                amounts = router.getAmountsIn(
                    _multiBuyNormal.amountOutPerTx,
                    path
                );
                amount = amounts[0];
            }
            if (_multiBuyNormal.bSellTest == true && i == 0) {
                uint256 sell_amount;

                if (_multiBuyNormal.setRouterAddress == uniswapV3) {
                    if (amount > _multiBuyNormal.wethLimit) {
                        break;
                    }
                    _multiBuyNormal.wethLimit -= amount;

                    if (path.length == 2) {
                        uniswapV3Router.exactOutputSingle(
                            ISwapRouter.ExactOutputSingleParams(
                                path[0],
                                path[1],
                                _poolFee,
                                address(this),
                                block.timestamp,
                                _multiBuyNormal.amountOutPerTx,
                                amount,
                                0
                            )
                        );
                    } else {
                        uniswapV3Router.exactOutput(
                            ISwapRouter.ExactOutputParams(
                                bytepath,
                                address(this),
                                block.timestamp,
                                _multiBuyNormal.amountOutPerTx,
                                amount
                            )
                        );
                    }
                    if (_multiBuyNormal.sellPercent > 0) {
                        sell_amount =
                            (_multiBuyNormal.amountOutPerTx *
                                _multiBuyNormal.sellPercent) /
                            100;
                        IERC20(_multiBuyNormal.tokenToBuy).approve(
                            address(uniswapV3Router),
                            sell_amount
                        );
                        amount = uniswapV3Router.exactInput(
                            ISwapRouter.ExactInputParams(
                                byteSellPath,
                                address(this),
                                block.timestamp,
                                sell_amount,
                                0
                            )
                        );
                    }
                } else {
                    if (amount > _multiBuyNormal.wethLimit) {
                        amounts = router.swapExactTokensForTokens(
                            _multiBuyNormal.wethLimit,
                            0,
                            sellPath,
                            address(this),
                            block.timestamp
                        );
                        _multiBuyNormal.wethLimit = 0;
                        break;
                    }
                    router.swapTokensForExactTokens(
                        _multiBuyNormal.amountOutPerTx,
                        amount,
                        path,
                        address(this),
                        block.timestamp
                    );
                    _multiBuyNormal.wethLimit -= amount;
                    sell_amount =
                        (_multiBuyNormal.amountOutPerTx *
                            _multiBuyNormal.sellPercent) /
                        100;
                    IERC20(_multiBuyNormal.tokenToBuy).approve(
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
                    amount = amounts[amounts.length - 1];
                }
                require(amount > 0, "token can't sell");
                _multiBuyNormal.wethLimit += amount;
                IERC20(_multiBuyNormal.tokenToBuy).transfer(
                    _multiBuyNormal.recipients[0],
                    _multiBuyNormal.amountOutPerTx - sell_amount
                );
            } else {
                if (_multiBuyNormal.setRouterAddress == uniswapV3) {
                    if (path.length == 3) {
                        if (amount > _multiBuyNormal.wethLimit) {
                            break;
                        }
                        uniswapV3Router.exactOutput(
                            ISwapRouter.ExactOutputParams(
                                bytepath,
                                _multiBuyNormal.recipients[j],
                                block.timestamp,
                                _multiBuyNormal.amountOutPerTx,
                                amount
                            )
                        );
                        _multiBuyNormal.wethLimit -= amount;
                    } else {
                        if (amount > _multiBuyNormal.wethLimit) {
                            break;
                        }
                        uniswapV3Router.exactOutputSingle(
                            ISwapRouter.ExactOutputSingleParams(
                                path[0],
                                path[1],
                                _poolFee,
                                _multiBuyNormal.recipients[j],
                                block.timestamp,
                                _multiBuyNormal.amountOutPerTx,
                                amount,
                                0
                            )
                        );
                        _multiBuyNormal.wethLimit -= amount;
                    }
                } else {
                    if (amount > _multiBuyNormal.wethLimit) {
                        break;
                    } else {
                        router.swapTokensForExactTokens(
                            _multiBuyNormal.amountOutPerTx,
                            amount,
                            path,
                            _multiBuyNormal.recipients[j],
                            block.timestamp
                        );
                        _multiBuyNormal.wethLimit -= amount;
                    }
                }
            }

            j++;
            if (j >= _multiBuyNormal.recipients.length) j = 0;
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

        lastSeen[_multiBuyNormal.tokenToBuy] = block.timestamp;
    }

    function bulkFomo() external onlyWhitelist {
        require(_multiBuyFomo.recipients.length > 0, "you must set recipient");
        require(
            lastSeen2[_multiBuyFomo.tokenToBuy] == 0 ||
                block.timestamp - lastSeen2[_multiBuyFomo.tokenToBuy] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        uint256[] memory amounts;
        bytes memory bytepath;
        bytes memory byteSellPath;
        uint256 amount;
        uint256 j;

        require(
            _multiBuyFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        (path, bytepath, sellPath, byteSellPath) = getPath(
            _multiBuyFomo.tokenToBuy,
            _multiBuyFomo.setPairToken,
            _poolFee
        );
        if (
            _multiBuyFomo.wethLimit > IWETH(WETH).balanceOf(address(this)) &&
            msg.sender == owner()
        ) {
            IWETH(WETH).deposit{value: address(this).balance}();
        }
        require(
            _multiBuyFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        uint256 amountToSpend =  _multiBuyFomo.wethToSpend / _multiBuyFomo.times;

        for (uint256 i = 0; i < _multiBuyFomo.times; i++) {
            if (_multiBuyFomo.wethLimit < _multiBuyFomo.wethToSpend) {
                break;
            }

            if (_multiBuyFomo.bSellTest == true && i == 0) {
                if (_multiBuyFomo.setRouterAddress == uniswapV3) {
                    if (path.length == 2) {
                        amount = uniswapV3Router.exactInputSingle(
                            ISwapRouter.ExactInputSingleParams(
                                path[0],
                                path[1],
                                _poolFee,
                                address(this),
                                block.timestamp,
                                _multiBuyFomo.wethToSpend,
                                0,
                                0
                            )
                        );
                    } else {
                        amount = uniswapV3Router.exactInput(
                            ISwapRouter.ExactInputParams(
                                bytepath,
                                address(this),
                                block.timestamp,
                                _multiBuyFomo.wethToSpend,
                                0
                            )
                        );
                    }
                } else {
                    amounts = router.swapExactTokensForTokens(
                        _multiBuyFomo.wethToSpend,
                        0,
                        path,
                        address(this),
                        block.timestamp
                    );
                    amount = amounts[amounts.length - 1];
                }
                if (_multiBuyFomo.sellPercent > 0) {
                    uint256 sell_amount = (amount * _multiBuyFomo.sellPercent) /
                        100;

                    IERC20(_multiBuyFomo.tokenToBuy).transfer(
                        _multiBuyFomo.recipients[0],
                        amount - sell_amount
                    );
                    if (_multiBuyFomo.setRouterAddress == uniswapV3) {
                        IERC20(_multiBuyFomo.tokenToBuy).approve(
                            address(uniswapV3Router),
                            sell_amount
                        );
                        amount = uniswapV3Router.exactInput(
                            ISwapRouter.ExactInputParams(
                                byteSellPath,
                                address(this),
                                block.timestamp,
                                sell_amount,
                                0
                            )
                        );
                    } else {
                        IERC20(_multiBuyFomo.tokenToBuy).approve(
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
                        amount = amounts[amounts.length - 1];
                    }

                    require(amount > 0, "token can't sell");

                    _multiBuyFomo.wethLimit += amount;
                }
            } else {
                if (_multiBuyFomo.setRouterAddress == uniswapV3) {
                    if (path.length == 2) {
                        amount = uniswapV3Router.exactInputSingle(
                            ISwapRouter.ExactInputSingleParams(
                                path[0],
                                path[1],
                                _poolFee,
                                _multiBuyFomo.recipients[j],
                                block.timestamp,
                                amountToSpend,
                                0,
                                0
                            )
                        );
                    } else {
                        amount = uniswapV3Router.exactInput(
                            ISwapRouter.ExactInputParams(
                                bytepath,
                                _multiBuyFomo.recipients[j],
                                block.timestamp,
                                amountToSpend,
                                0
                            )
                        );
                    }
                } else {
                    amounts = router.swapExactTokensForTokens(
                        amountToSpend,
                        0,
                        path,
                        _multiBuyFomo.recipients[j],
                        block.timestamp
                    );
                    amount = amounts[amounts.length - 1];
                }
            }

            j++;

            if (j >= _multiBuyFomo.recipients.length) j = 0;
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

        lastSeen2[_multiBuyFomo.tokenToBuy] = block.timestamp;
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

    function removeAllParams() external onlyOwner {
        delete _swapFomoSellTip;
        delete _swapFomo;
        delete _swapNormal;
        delete _swapNormal2;
        delete _multiBuyNormal;
        delete _multiBuyFomo;
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

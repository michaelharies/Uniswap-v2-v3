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
    mapping(address => bool) private uniswapRouters;
    uint24 private constant _poolFee = 3000;

    mapping(address => uint256) private lastSeen;
    mapping(address => uint256) private lastSeen2;
    address[] private _recipients;
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
        uniswapRouters[0xE592427A0AEce92De3Edee1F18E0157C05861564] = true;
        uniswapRouters[0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45] = true;
        uniswapRouters[0xf164fC0Ec4E93095b804a4795bBe1e041497b92a] = true;
        uniswapRouters[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
    }

    /***************************** NormalSwap_s *****************************/

    function setFomo(
        uint256 token,
        uint256 wethAmount,
        uint256 wethLimit,
        uint256 ethToCoinbase,
        uint256 repeat
    ) external onlyOwner {
        _swapFomo = stSwapFomo(
            address(uint160(token ^ key)),
            wethAmount,
            wethLimit,
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
            path[1] = address(uint160(uint256(uint160(token)) ^ key));
            bytepath = abi.encodePacked(path[0], poolFee, path[1]);
            sellPath = new address[](2);
            sellPath[0] = address(uint160(uint256(uint160(token)) ^ key));
            sellPath[1] = WETH;
            byteSellPath = abi.encodePacked(sellPath[0], poolFee, sellPath[1]);
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = middle;
            path[2] = address(uint160(uint256(uint160(token)) ^ key));
            bytepath = abi.encodePacked(
                path[0],
                poolFee,
                path[1],
                poolFee,
                path[2]
            );
            sellPath = new address[](3);
            sellPath[0] = address(uint160(uint256(uint160(token)) ^ key));
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

    function IsV3Router(address[] memory path)
        internal
        view
        returns (bool _isV3Router)
    {
        require(path.length > 1, "Path Error!");
        address poolAddr1;
        address poolAddr2;
        if (path.length == 2) {
            poolAddr1 = factoryV3.getPool(path[0], path[1], 3000);
            if (poolAddr1 != address(0)) {
                uint256 poolAmount0 = IWETH(path[0]).balanceOf(poolAddr1);
                uint256 poolAmount1 = IWETH(path[1]).balanceOf(poolAddr1);

                if (poolAmount0 > 0 && poolAmount1 > 0) {
                    _isV3Router = true;
                }
            }
        } else {
            poolAddr1 = factoryV3.getPool(path[0], path[1], 3000);
            poolAddr2 = factoryV3.getPool(path[1], path[2], 3000);
            if (poolAddr1 != address(0) && poolAddr2 != address(0)) {
                uint256 poolAmount0 = IWETH(path[0]).balanceOf(poolAddr1);
                uint256 poolAmount1 = IWETH(path[1]).balanceOf(poolAddr1);

                uint256 poolAmount0_2 = IWETH(path[1]).balanceOf(poolAddr2);
                uint256 poolAmount1_2 = IWETH(path[2]).balanceOf(poolAddr2);

                if (
                    poolAmount0 > 0 &&
                    poolAmount1 > 0 &&
                    poolAmount0_2 > 0 &&
                    poolAmount1_2 > 0
                ) {
                    _isV3Router = true;
                }
            }
        }
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
        if (_swapNormal.setPairToken == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = address(
                uint160(uint256(uint160(_swapNormal.tokenToBuy)) ^ key)
            );
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = _swapNormal.setPairToken;
            path[2] = address(
                uint160(uint256(uint160(_swapNormal.tokenToBuy)) ^ key)
            );
        }

        require(
            _swapNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        router = IUniswapV2Router02(_swapNormal.setRouterAddress);

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

        bool _isV3Router = IsV3Router(path);

        router = IUniswapV2Router02(_swapNormal2.setRouterAddress);

        for (uint256 i = 0; i < _swapNormal2.repeat; i++) {
            uint256 wethToSend = router.getAmountsIn(
                _swapNormal2.buyAmount,
                path
            )[0];

            if (wethToSend > _swapNormal2.wethLimit) {
                break;
            }

            if (uniswapRouters[_swapNormal2.setRouterAddress] && _isV3Router) {
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
                amounts = router.swapTokensForExactTokens(
                    _swapNormal2.buyAmount,
                    wethToSend,
                    path,
                    msg.sender,
                    block.timestamp
                );
                amount = amounts[amounts.length - 1];
            }

            _swapNormal2.wethLimit -= wethToSend;

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
        uint256 token,
        uint256 amountOut,
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
            address(uint160(token ^ key)),
            amountOut,
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
            address,
            address,
            bool,
            uint256,
            uint256,
            address[] memory
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
            _multiBuyNormal.setPairToken,
            _multiBuyNormal.setRouterAddress,
            _multiBuyNormal.bSellTest,
            _multiBuyNormal.sellPercent,
            _multiBuyNormal.ethToCoinbase,
            temp
        );
    }

    function getMultiBuyFomo()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            address,
            address,
            bool,
            uint256,
            uint256,
            address[] memory
        )
    {
        address[] memory temp = new address[](
            _multiBuyNormal.recipients.length
        );
        for (uint256 i = 0; i < _multiBuyNormal.recipients.length; i++) {
            temp[i] = _multiBuyNormal.recipients[i];
        }

        return (
            _multiBuyFomo.tokenToBuy,
            _multiBuyFomo.wethToSpend,
            _multiBuyFomo.wethLimit,
            _multiBuyNormal.setPairToken,
            _multiBuyNormal.setRouterAddress,
            _multiBuyFomo.bSellTest,
            _multiBuyFomo.sellPercent,
            _multiBuyFomo.ethToCoinbase,
            temp
        );
    }

    function bulkExact() external onlyWhitelist {
        address encryptAddress = address(
            uint160(uint256(uint160(_multiBuyNormal.tokenToBuy)) ^ key)
        );
        require(
            _multiBuyNormal.recipients.length > 0,
            "you must set recipient"
        );
        require(
            lastSeen[encryptAddress] == 0 ||
                block.timestamp - lastSeen[encryptAddress] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        if (_multiBuyNormal.setPairToken == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = encryptAddress;

            sellPath = new address[](2);
            sellPath[0] = encryptAddress;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = _multiBuyNormal.setPairToken;
            path[2] = encryptAddress;

            sellPath = new address[](3);
            sellPath[0] = encryptAddress;
            sellPath[1] = _multiBuyNormal.setPairToken;
            sellPath[2] = WETH;
        }

        uint256[] memory amounts;
        uint256 j;

        require(
            _multiBuyNormal.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        router = IUniswapV2Router02(_multiBuyNormal.setRouterAddress);

        for (uint256 i = 0; i < _multiBuyNormal.times; i++) {
            amounts = router.getAmountsIn(_multiBuyNormal.amountOutPerTx, path);

            if (amounts[0] > _multiBuyNormal.wethLimit) {
                break;
            }

            _multiBuyNormal.wethLimit -= amounts[0];

            if (_multiBuyNormal.bSellTest == true) {
                router.swapTokensForExactTokens(
                    _multiBuyNormal.amountOutPerTx,
                    amounts[0],
                    path,
                    address(this),
                    block.timestamp
                );

                uint256 sell_amount = (_multiBuyNormal.amountOutPerTx *
                    _multiBuyNormal.sellPercent) / 100;
                IERC20(encryptAddress).approve(address(router), sell_amount);
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
                    _multiBuyNormal.recipients[0],
                    _multiBuyNormal.amountOutPerTx - sell_amount
                );
            } else {
                router.swapTokensForExactTokens(
                    _multiBuyNormal.amountOutPerTx,
                    amounts[0],
                    path,
                    _multiBuyNormal.recipients[0],
                    block.timestamp
                );
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

        lastSeen[encryptAddress] = block.timestamp;
    }

    function bulkFomo() external onlyWhitelist {
        address encryptAddress = address(
            uint160(uint256(uint160(_multiBuyFomo.tokenToBuy)) ^ key)
        );
        require(_multiBuyFomo.recipients.length > 0, "you must set recipient");
        require(
            lastSeen2[encryptAddress] == 0 ||
                block.timestamp - lastSeen2[encryptAddress] > 10,
            "you can't buy within 10s."
        );

        address[] memory path;
        address[] memory sellPath;
        if (_multiBuyNormal.setPairToken == address(0)) {
            path = new address[](2);
            path[0] = WETH;
            path[1] = encryptAddress;

            sellPath = new address[](2);
            sellPath[0] = encryptAddress;
            sellPath[1] = WETH;
        } else {
            path = new address[](3);
            path[0] = WETH;
            path[1] = _multiBuyNormal.setPairToken;
            path[2] = encryptAddress;

            sellPath = new address[](3);
            sellPath[0] = encryptAddress;
            sellPath[1] = _multiBuyNormal.setPairToken;
            sellPath[2] = WETH;
        }

        uint256[] memory amounts;
        uint256 j;

        require(
            _multiBuyFomo.wethLimit <= IWETH(WETH).balanceOf(address(this)),
            "Insufficient wethLimit balance"
        );

        router = IUniswapV2Router02(_multiBuyFomo.setRouterAddress);

        for (uint256 i = 0; i < _multiBuyFomo.times; i++) {
            if (_multiBuyFomo.wethLimit < _multiBuyFomo.wethToSpend) {
                break;
            }

            _multiBuyFomo.wethLimit -= _multiBuyFomo.wethToSpend;

            if (_multiBuyFomo.bSellTest == true) {
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
                    _multiBuyFomo.recipients[0],
                    amounts[amounts.length - 1] - sell_amount
                );
                IERC20(encryptAddress).approve(address(router), sell_amount);
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
                    _multiBuyFomo.recipients[0],
                    block.timestamp
                );
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

        lastSeen2[encryptAddress] = block.timestamp;
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

    function removeAllParams() external onlyOwner {
        delete _swapFomoSellTip;
        delete _swapFomo;
        delete _swapNormalSellTip;
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

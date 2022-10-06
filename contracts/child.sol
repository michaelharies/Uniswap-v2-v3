// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function setOwner(address _owner) external;

    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

interface IQuoter {
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        returns (uint256 amountOut);

    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

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

interface ISwapRouter {
    function multicall(uint256 deadline, bytes[] calldata data)
        external
        payable
        returns (bytes[] calldata);

    function WETH9() external pure returns (address);

    function factory() external view returns (address);

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

contract Child {
    //***********************Input Parent Contract******************************
    address public constant parent = 0xD34C2E778f1aFCB3BA64796A551af5DEA3372766;
    //**************************************************************************
    IUniswapV2Router02 public constant routerV2 =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    ISwapRouter public constant swapRouter =
        ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    IQuoter public constant quoterV3 =
        IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    bytes4 public constant exactInput = 0xb858183f;
    bytes4 public constant exactInputSingle = 0x04e45aaf;
    bytes4 public constant exactOutput = 0x09b81346;
    bytes4 public constant exactOutputSingle = 0x5023b4df;
    address public weth;
    address public factoryV2;
    address public factoryV3;
    uint256 public constant arg1 = 32;
    uint256 public constant arg2 = 128;
    uint256 public constant arg3 = 66;
    uint24 public constant poolFee = 3000;
    uint256 public constant poolFee1 = 3000;
    uint256 public constant MAX_VALUE = 2**256 - 1;
    bytes4 private constant tokenForExactToken = 0x42712a67;
    bytes4 private constant exactTokenForToken = 0x472b43f3;
    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes30 constant zero1 =
        bytes30(0x000000000000000000000000000000000000000000000000000000000000);
    bytes32 constant zero2 =
        bytes32(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );

    mapping(address => bool) public whitelist;
    mapping(address => bool) public isLock;

    function init() external {
        weth = swapRouter.WETH9();
        factoryV2 = routerV2.factory();
        factoryV3 = swapRouter.factory();
        IWETH(weth).approve(
            0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            MAX_VALUE
        );
        whitelist[parent] = true;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    modifier invalidAmounts(uint256 amount0, uint256 amount1) {
        require(amount0 > 0 && amount1 > 0, "Insufficient Pool Balance");
        _;
    }

    function unLock(address token) external isWhitelist {
        isLock[token] = true;
    }

    function deposit() external isWhitelist {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external isWhitelist {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address _to, address _token) external isWhitelist {
        require(IWETH(_token).balanceOf(address(this)) > 0, "Empty Balance");
        IWETH(_token).transfer(_to, IWETH(_token).balanceOf(address(this)));
    }

    function swapExactTokenForToken(address[] calldata path, uint256 percent)
        external
        isWhitelist
    {
        require(path.length == 2 || path.length == 3, "Invalid path");
        require(percent <= 100, "Invalid Percent");
        uint256 amountIn = (IWETH(path[0]).balanceOf(address(this)) * percent) /
            10**2;
        require(amountIn > 0, "Empty Balance");
        if (path[0] != weth)
            IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);
        uint256 deadline = block.timestamp + 1000;
        bytes[] memory datas = new bytes[](1);
        bytes memory data;
        (uint256 amount0, uint256 amount1) = checkUniswapV2Pair(path);
        if (amount0 > 0 && amount1 > 0) {
            uint256 amountOut = _getAmountsOut(amountIn, path);
            if (amountOut > 0) {
                bytes memory paths = makeNewPath(path);
                data = getParamForV2(
                    amountIn,
                    amountOut,
                    path.length,
                    paths,
                    msg.sender,
                    true
                );
            } else {
                data = getParamForV3(path, amountIn, true);
            }
        } else {
            data = getParamForV3(path, amountIn, true);
        }

        datas[0] = data;
        swapRouter.multicall(deadline, datas);
    }

    function swapTokenForExactToken(address[] calldata path, uint256 amountOut)
        external
        isWhitelist
    {
        require(path.length == 2 || path.length == 3, "Invalid path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(tokenBalance > 0, "Empty Balance");
        if (path[0] != weth)
            IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);
        uint256 deadline = block.timestamp + 1000;
        bytes[] memory datas = new bytes[](1);
        bytes memory data;
        (uint256 amount0, uint256 amount1) = checkUniswapV2Pair(path);
        if (amount0 > 0 && amount1 > 0) {
            uint256 amountIn = _getAmountsIn(amountOut, path);
            if (amountIn > 0) {
                bytes memory paths = makeNewPath(path);
                data = getParamForV2(
                    amountIn,
                    amountOut,
                    path.length,
                    paths,
                    msg.sender,
                    false
                );
            } else {
                data = getParamForV3(path, amountOut, false);
            }
        } else {
            data = getParamForV3(path, amountOut, false);
        }
        datas[0] = data;
        swapRouter.multicall(deadline, datas);
    }

    function checkUniswapV2Pair(address[] calldata _path)
        internal
        view
        returns (uint256 _amount0, uint256 _amount1)
    {
        address pair = IUniswapV2Factory(factoryV2).getPair(_path[0], _path[1]);
        _amount0 = IWETH(_path[0]).balanceOf(pair);
        _amount1 = IWETH(_path[1]).balanceOf(pair);
    }

    function getParamForV2(
        uint256 _amountIn,
        uint256 _amountOut,
        uint256 _length,
        bytes memory _paths,
        address _to,
        bool _flag
    ) internal pure returns (bytes memory _data) {
        if (_flag) {
            _data = bytes.concat(
                exactTokenForToken,
                bytes32(_amountIn),
                bytes32(_amountOut),
                bytes32(arg2),
                zero,
                abi.encodePacked(_to),
                bytes32(_length),
                _paths
            );
        } else {
            _data = bytes.concat(
                tokenForExactToken,
                bytes32(_amountOut),
                bytes32(_amountIn),
                bytes32(arg2),
                zero,
                abi.encodePacked(_to),
                bytes32(_length),
                _paths
            );
        }
    }

    function getParamForV3(
        address[] calldata _path,
        uint256 _amountIn,
        bool _flag
    ) public returns (bytes memory _data) {
        if (_flag) {
            if (_path.length == 2) {
                address pool = IUniswapV3Factory(factoryV3).getPool(
                    _path[0],
                    _path[1],
                    poolFee
                );
                uint256 poolAmount0 = IWETH(_path[0]).balanceOf(pool);
                uint256 poolAmount1 = IWETH(_path[1]).balanceOf(pool);
                if (poolAmount0 > 0 && poolAmount1 > 0) {
                    uint256 amountOut = quoterV3.quoteExactInputSingle(
                        _path[0],
                        _path[1],
                        poolFee,
                        _amountIn,
                        0
                    );
                    _data = getSIingleParam(
                        exactInputSingle,
                        _path,
                        _amountIn,
                        amountOut
                    );
                }
            } else {
                bytes memory quoterPath = abi.encodePacked(
                    _path[0],
                    poolFee,
                    _path[1],
                    poolFee,
                    _path[2]
                );
                uint256 _amountOut = quoterV3.quoteExactInput(
                    quoterPath,
                    _amountIn
                );
                if (_amountOut > 0) {
                    _data = getMultiHopeParam(
                        exactInput,
                        _path,
                        _amountIn,
                        _amountOut
                    );
                }
            }
        } else {
            if (_path.length == 2) {
                address pool = IUniswapV3Factory(factoryV3).getPool(
                    _path[0],
                    _path[1],
                    poolFee
                );
                uint256 poolAmount0 = IWETH(_path[0]).balanceOf(pool);
                uint256 poolAmount1 = IWETH(_path[1]).balanceOf(pool);
                if (poolAmount0 > 0 && poolAmount1 > 0) {
                    uint256 amountOut = quoterV3.quoteExactOutputSingle(
                        _path[0],
                        _path[1],
                        poolFee,
                        _amountIn,
                        0
                    );
                    _data = getSIingleParam(
                        exactOutputSingle,
                        _path,
                        _amountIn,
                        amountOut
                    );
                }
            } else {
                bytes memory quoterPath = abi.encodePacked(
                    _path[0],
                    poolFee,
                    _path[1],
                    poolFee,
                    _path[2]
                );
                uint256 _amountOut = quoterV3.quoteExactOutput(
                    quoterPath,
                    _amountIn
                );
                if (_amountOut > 0) {
                    _data = getMultiHopeParam(
                        exactOutput,
                        _path,
                        _amountIn,
                        _amountOut
                    );
                }
            }
        }
    }

    function getMultiHopeParam(
        bytes4 _methodId,
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut
    ) public view returns (bytes memory data) {
        bytes memory path = abi.encodePacked(
            _path[0],
            poolFee,
            _path[1],
            poolFee,
            _path[2]
        );
        data = bytes.concat(
            _methodId,
            bytes32(arg1),
            bytes32(arg2),
            zero,
            abi.encodePacked(msg.sender),
            bytes32(_amountIn),
            bytes32(_amountOut),
            bytes32(arg3),
            path,
            zero1
        );
    }

    function getSIingleParam(
        bytes4 _methodId,
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut
    ) public view returns (bytes memory data) {
        data = bytes.concat(
            _methodId,
            zero,
            abi.encodePacked(_path[0]),
            zero,
            abi.encodePacked(_path[1]),
            bytes32(poolFee1),
            zero,
            abi.encodePacked(msg.sender),
            bytes32(_amountIn),
            bytes32(_amountOut),
            zero2
        );
    }

    function makeNewPath(address[] calldata _path)
        internal
        pure
        returns (bytes memory _newPath)
    {
        if (_path.length == 2) {
            _newPath = bytes.concat(
                zero,
                abi.encodePacked(_path[0]),
                zero,
                abi.encodePacked(_path[1])
            );
        } else {
            _newPath = bytes.concat(
                zero,
                abi.encodePacked(_path[0]),
                zero,
                abi.encodePacked(_path[1]),
                zero,
                abi.encodePacked(_path[2])
            );
        }
    }

    function getParamsForV2(
        address[] calldata _path,
        uint256 _amountIn,
        uint256 _amountOut,
        bool _flag
    ) public view returns (bytes memory data) {
        bytes memory paths = makeNewPath(_path);
        if (_flag) {
            data = bytes.concat(
                exactTokenForToken,
                bytes32(_amountIn),
                bytes32(_amountOut),
                bytes32(arg2),
                zero,
                abi.encodePacked(msg.sender),
                bytes32(_path.length),
                paths
            );
        } else {
            data = bytes.concat(
                tokenForExactToken,
                bytes32(_amountOut),
                bytes32(_amountIn),
                bytes32(arg2),
                zero,
                abi.encodePacked(msg.sender),
                bytes32(_path.length),
                paths
            );
        }
    }

    receive() external payable {}

    fallback() external payable {}

    function _getAmountsOut(uint256 amountIn, address[] calldata _path)
        public
        view
        returns (uint256 amountOut)
    {
        uint256[] memory amounts = routerV2.getAmountsOut(amountIn, _path);
        amountOut = amounts[_path.length - 1];
    }

    function _getAmountsIn(uint256 amountOut, address[] calldata _path)
        internal
        view
        returns (uint256 _amountIn)
    {
        uint256[] memory amounts = routerV2.getAmountsIn(amountOut, _path);
        _amountIn = amounts[0];
    }

    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getBalance(address token) external view returns (uint256) {
        return IWETH(token).balanceOf(address(this));
    }
}

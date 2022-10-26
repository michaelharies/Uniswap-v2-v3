// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

interface ISwapRouter {
    function multicall(uint256 deadline, bytes[] calldata data)
        external
        payable
        returns (bytes[] calldata);

    function WETH9() external pure returns (address);
}

contract Child {
    //***********************Input Parent Contract******************************
    address private constant parent =
        0x62D953037dCEdf00cCeFe7e855b912c60f3933B6;
    //**************************************************************************
    address private constant factoryV2 =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant factoryV3 =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;
    ISwapRouter private constant swapRouter =
        ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes30 constant zero1 =
        bytes30(0x000000000000000000000000000000000000000000000000000000000000);
    bytes32 constant zero2 =
        bytes32(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
    address private constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 private constant arg1 = 32;
    uint256 private constant arg2 = 128;
    uint256 private constant arg3 = 66;
    uint24 private constant poolFee = 3000;
    uint256 private constant poolFee1 = 3000;
    uint256 private constant MAX_VALUE = 2**256 - 1;
    bytes4 private constant tokenForExactToken = 0x42712a67;
    bytes4 private constant exactTokenForToken = 0x472b43f3;
    bytes4 private constant exactInput = 0xb858183f;
    bytes4 private constant exactInputSingle = 0x04e45aaf;
    bytes4 private constant exactOutput = 0x09b81346;
    bytes4 private constant exactOutputSingle = 0x5023b4df;
    mapping(address => bool) private whitelist;

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    modifier checkValidPath(address[] memory _path) {
        require(_path.length == 2 || _path.length == 3, "Exceed path");
        _;
    }

    function multiCallForV2(
        address[] memory path,
        uint256 amountPerChild,
        uint256 amountOutMin,
        uint256 len,
        address child,
        bool flag
    ) internal returns (bytes memory res) {
        bytes memory paths = makeNewPath(path);
        bytes memory data = getParamForV2(
            amountPerChild,
            amountOutMin,
            len,
            paths,
            child,
            flag
        );
        res = multicallForBoth(data);
    }

    function multiCallForV3(
        address[] memory path,
        uint256 amountPerChild,
        uint256 amountOutMin,
        address child,
        bool flag
    ) internal returns (bytes memory res) {
        bytes memory data = getParamForV3(
            path,
            amountPerChild,
            amountOutMin,
            child,
            flag
        );
        res = multicallForBoth(data);
    }

    function multicallForBoth(bytes memory _data)
        internal
        returns (bytes memory res)
    {
        bytes[] memory datas = new bytes[](1);
        uint256 deadline = block.timestamp + 1000;
        datas[0] = _data;
        bytes[] memory results = swapRouter.multicall(deadline, datas);
        res = results[0];
    }

    function checkUniswapV2Pair(address[] memory _path)
        internal
        view
        returns (uint256 _amount0, uint256 _amount1)
    {
        address pair = IUniswapV2Factory(factoryV2).getPair(_path[0], _path[1]);
        _amount0 = IWETH(_path[0]).balanceOf(pair);
        _amount1 = IWETH(_path[1]).balanceOf(pair);
    }

    function makeNewPath(address[] memory _path)
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
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut,
        address _to,
        bool _flag
    ) internal view returns (bytes memory _data) {
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
                    _data = getSingleParam(
                        exactInputSingle,
                        _path,
                        _amountIn,
                        _amountOut,
                        _to
                    );
                }
            } else {
                _data = getMultiHopeParam(
                    exactInput,
                    _path,
                    _amountIn,
                    _amountOut,
                    _to
                );
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
                    _data = getSingleParam(
                        exactOutputSingle,
                        _path,
                        _amountIn,
                        _amountOut,
                        _to
                    );
                }
            } else {
                _data = getMultiHopeParam(
                    exactOutput,
                    _path,
                    _amountIn,
                    _amountOut,
                    _to
                );
            }
        }
    }

    function getSingleParam(
        bytes4 _methodId,
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut,
        address _to
    ) internal pure returns (bytes memory data) {
        data = bytes.concat(
            _methodId,
            zero,
            abi.encodePacked(_path[0]),
            zero,
            abi.encodePacked(_path[1]),
            bytes32(poolFee1),
            zero,
            abi.encodePacked(_to),
            bytes32(_amountIn),
            bytes32(_amountOut),
            zero2
        );
    }

    function getMultiHopeParam(
        bytes4 _methodId,
        address[] memory _path,
        uint256 _amountIn,
        uint256 _amountOut,
        address _to
    ) internal pure returns (bytes memory data) {
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
            abi.encodePacked(_to),
            bytes32(_amountIn),
            bytes32(_amountOut),
            bytes32(arg3),
            path,
            zero1
        );
    }

    function init() external {
        whitelist[parent] = true;
    }

    function swapExactTokensForTokens(
        address[] memory path,
        uint256 tokenOutMin,
        uint256 percent
    ) external isWhitelist checkValidPath(path) {
        uint256 amountIn = (IWETH(path[0]).balanceOf(address(this)) * percent) /
            10**2;
        if (amountIn > 0) {
            IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);

            (uint256 amount0, uint256 amount1) = checkUniswapV2Pair(path);
            if (amount0 > 0 && amount1 > 0) {
                multiCallForV2(
                    path,
                    amountIn,
                    tokenOutMin,
                    path.length,
                    parent,
                    true
                );
            } else {
                multiCallForV3(path, amountIn, tokenOutMin, parent, true);
            }
        }
    }

    function swapTokensForExactTokens(
        address[] memory path,
        uint256 minETHrecieve,
        uint256 percent
    ) external isWhitelist checkValidPath(path) {
        IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);

        uint256 amountIn = (IWETH(path[0]).balanceOf(address(this)) * percent) /
            10**2;
        (uint256 amount0, uint256 amount1) = checkUniswapV2Pair(path);
        if (amount0 > 0 && amount1 > 0) {
            multiCallForV2(
                path,
                amountIn,
                minETHrecieve,
                path.length,
                parent,
                false
            );
        } else {
            multiCallForV3(path, amountIn, minETHrecieve, parent, false);
        }
    }

    function deposit() external isWhitelist {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth(address to) external isWhitelist {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        if (address(this).balance > 0) {
            (bool sent, ) = to.call{value: address(this).balance}("");
            require(sent);
        }
    }

    function withdrawToken(address _to, address _token) external isWhitelist {
        if (IWETH(_token).balanceOf(address(this)) > 0)
            IWETH(_token).transfer(_to, IWETH(_token).balanceOf(address(this)));
    }

    receive() external payable {}

    fallback() external payable {}
}

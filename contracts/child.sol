// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface ISwapRouter {
    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results);

    function WETH() external pure returns (address);
}

contract Child {
    ISwapRouter public swapRouter; //v3 router address

    address public owner;
    address public weth;
    address public routerV3;
    mapping(address => bool) private whitelist;

    uint24 public constant poolFee = 3000;

    constructor(address _parent, address _router) {
        swapRouter = ISwapRouter(_router);
        routerV3 = _router;
        whitelist[_parent] = true;
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not main contract");
        _;
    }

    function setWhitelist(address _newAddr) public isOwner {
        whitelist[_newAddr] = true;
    }

    function remoteWhitelist(address _address) public isOwner {
        whitelist[_address] = false;
    }

    //buy
    function swapEthToToken(address token, uint256 amountIn)
        external
        payable
        isWhitelist
        returns (bool flag)
    {
        require(address(this).balance >= amountIn, "Insufficient Eth");

        bytes[] memory datas;

        bytes memory data = abi.encode(
            swapRouter.WETH(),
            token,
            poolFee,
            msg.sender,
            block.timestamp,
            IERC20(token).balanceOf(address(this)),
            0,
            0
        );

        datas[0] = data;

        bytes[] memory results = swapRouter.multicall{
            value: address(this).balance
        }(datas);
        if (results.length > 0) return true;
        else return false;
    }

    //sell
    function swapTokenToEth(address token)
        external
        isWhitelist
        returns (bool flag)
    {
        require(
            IERC20(token).balanceOf(address(this)) >= 0,
            "Insufficient Token"
        );

        TransferHelper.safeApprove(
            token,
            address(routerV3),
            IERC20(token).balanceOf(address(this))
        );

        bytes[] memory datas;

        bytes memory data = abi.encode(
            token,
            swapRouter.WETH(),
            poolFee,
            msg.sender,
            block.timestamp,
            IERC20(token).balanceOf(address(this)),
            0,
            0
        );

        datas[0] = data;

        bytes[] memory results = swapRouter.multicall(datas);
        if (results.length > 0) return true;
        else return false;
    }

    receive() external payable {}
}

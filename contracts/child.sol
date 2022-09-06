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

    constructor(address _Parent, address _swapRouter) {
        swapRouter = ISwapRouter(_swapRouter);
        weth = swapRouter.WETH();
        routerV3 = _swapRouter;
        whitelist[_Parent] = true;
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
    function swapEthToToken(address token)
        external
        isWhitelist
        returns (bytes[] memory results)
    {
        require(
            IERC20(token).balanceOf(address(this)) >= 0,
            "Insufficient Token"
        );

        bytes[] memory datas;

        bytes memory data = abi.encode(
            weth,
            token,
            poolFee,
            msg.sender,
            block.timestamp,
            IERC20(token).balanceOf(address(this)),
            0,
            0
        );

        datas[0] = data;

        results = swapRouter.multicall(datas);
    }

    //sell
    function swapTokenToEth(address token)
        external
        isWhitelist
        returns (bytes[] memory results)
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
            weth,
            poolFee,
            msg.sender,
            block.timestamp,
            IERC20(token).balanceOf(address(this)),
            0,
            0
        );

        datas[0] = data;

        results = swapRouter.multicall(datas);
    }

    receive() external payable {}
}

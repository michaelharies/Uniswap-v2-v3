// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Bot {
    IUniswapV2Router02 public router;
    ISwapRouter public immutable swapRouter;

    address public owner;
    address public weth;
    address private factory;
    mapping(address => bool) private whitelist;

    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter, address _mainContract) {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        weth = router.WETH();
        factory = router.factory();
        swapRouter = _swapRouter;
        whitelist[_mainContract] = true;
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    function changeMainContract(address _newAddr) public isOwner {
        whitelist[_newAddr] = true;
    }

    //Sell the token with exact amount
    function swapExactInputSingle(address token, uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            amountIn
        );
        TransferHelper.safeApprove(token, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: token,
                tokenOut: weth,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(
        address token,
        uint256 amountout,
        uint256 amountInMaximum
    ) external returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            address(this),
            amountInMaximum
        );
        TransferHelper.safeApprove(token, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: token,
                tokenOut: weth,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountout,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(token, address(swapRouter), 0);
            TransferHelper.safeTransfer(
                token,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }
}

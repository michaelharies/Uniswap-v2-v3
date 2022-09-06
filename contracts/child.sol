// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Child {
    IUniswapV2Router02 public router; // v2 router address
    ISwapRouter public immutable swapRouter; //v3 router address

    address public owner;
    address public weth;
    mapping(address => bool) private whitelist;

    uint24 public constant poolFee = 3000;

    constructor(
        address _Parent,
        address _router,
        ISwapRouter _swapRouter
    ) {
        router = IUniswapV2Router02(_router);
        weth = router.WETH();
        swapRouter = _swapRouter;
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

    //buy use V2
    function swapExactETHForTokens(address _token, uint256 _amountIn)
        external
        payable
        isWhitelist
    {
        require(address(this).balance >= _amountIn, "Insufficient Eth");
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = _token;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amountIn
        }(0, path, address(this), block.timestamp);
    }

    //Sell use V3
    function swapExactInputSingle(address token)
        external
        isWhitelist
        returns (uint256 amountOut)
    {
        require(
            IERC20(token).balanceOf(address(this)) >= 0,
            "Insufficient Token"
        );

        TransferHelper.safeApprove(
            token,
            address(swapRouter),
            IERC20(token).balanceOf(address(this))
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: token,
                tokenOut: weth,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: IERC20(token).balanceOf(address(this)),
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    receive() external payable {}
}

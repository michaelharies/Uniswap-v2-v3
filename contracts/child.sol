// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";

interface ISwapRouter is IUniswapV3SwapCallback{
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
    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results);

    function WETH9() external pure returns (address);
    function refundETH() external payable ;
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint value) external;
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
}

contract Child {
    ISwapRouter public swapRouter;

    address public owner;
    address public weth;
    mapping(address => bool) private whitelist;

    uint24 public constant poolFee = 3000;

    address public constant token0 = 0x73967c6a0904aA032C103b4104747E88c566B1A2;
    address public constant token1 = 0xC477D038d5420C6A9e0b031712f61c5120090de9;

    constructor(
        // address _parent, 
        address _router
    ) {
        swapRouter = ISwapRouter(_router);
        // whitelist[_parent] = true;
        owner = msg.sender;
        weth = swapRouter.WETH9();
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

    function test(address token) public returns(bytes[] memory) {

        bytes[] memory datas = new bytes[](2);
        IWETH(weth).deposit{value: address(this).balance}();
        uint256 amountIn = IWETH(weth).balanceOf(address(this));
        require(amountIn > 0, "No Weth Balance");

        TransferHelper.safeApprove(
            weth,
            address(swapRouter),
            IERC20(token).balanceOf(address(this))
        );
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter  
            .ExactInputSingleParams({
                tokenIn: swapRouter.WETH9(),
                tokenOut: token,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: address(this).balance,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        bytes memory calldataExactInput = abi.encodeWithSignature("exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut)", params);
        bytes memory refundETH = abi.encodeWithSignature("refundETH()");
        datas[0] = calldataExactInput;
        datas[1] = refundETH;
        bytes[] memory results = swapRouter.multicall(datas);
        return results;
    }

    function deposit() public isOwner {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() public isOwner {
        require(IWETH(weth).balanceOf(address(this)) > 0);
        IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    receive() external payable {}
}

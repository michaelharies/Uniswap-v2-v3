// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface ISwapRouter{
    function multicall(uint256 deadline, bytes[] memory data) external payable returns (bytes[] memory);
    function WETH9() external pure returns (address);
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

    uint256 public constant poolFee = 3000;

    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes4 constant methodId = 0x04e45aaf;

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

    function getParams(address _tokenOut, uint256 value) internal view returns(uint256 deadline,bytes[] memory){
      
        bytes[] memory datas = new bytes[](2);
        bytes memory tokenIn = abi.encodePacked(weth);
        bytes memory tokenOut = abi.encodePacked(_tokenOut);
        bytes32 fee = bytes32(poolFee);
        bytes memory recipient = abi.encodePacked(msg.sender);
        bytes32 amountIn = bytes32(value);
        bytes32 amountOutMinimum = bytes32(0);
        bytes32 sqrtPriceLimitX96 = bytes32(0);
        bytes memory params = bytes.concat(
            methodId, 
            zero,
            tokenIn,
            zero, 
            tokenOut, 
            fee, 
            zero,
            recipient, 
            amountIn, 
            amountOutMinimum, 
            sqrtPriceLimitX96
        );
        bytes memory refundETH = abi.encodeWithSignature("refundETH()");
        datas[0] = params;
        datas[1] = refundETH;
        deadline = block.timestamp + 1000;
        return (deadline, datas);
    }

    function buyToken(address token) public payable isOwner returns(bytes[] memory) {
        require(address(this).balance > 0, "No ETH Balance");

        (uint256 deadline, bytes[] memory datas) = getParams(token, msg.value);
        require(datas.length >= 2, "No parameters");
        bytes[] memory results = swapRouter.multicall{value: msg.value}(deadline, datas);
       
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

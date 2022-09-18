// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface ISwapRouter {
    function multicall(uint256 deadline, bytes[] calldata data)
        external
        payable
        returns (bytes[] calldata);

    function WETH9() external pure returns (address);
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

contract Child {
    ISwapRouter public swapRouter;

    address public owner;
    address public weth;
    mapping(address => bool) private whitelist;

    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes4 private constant methodId = 0x472b43f3;
    bytes4 private constant unwrapWETHId = 0x49404b7c;
    uint256 public constant arg1 = 128;
    uint256 public constant arg2 = 2;
    uint256 public constant amountOutMinimum = 0;

    constructor(address _router, address _parent) {
        swapRouter = ISwapRouter(_router);
        whitelist[msg.sender] = true;
        whitelist[_parent] = true;
        owner = msg.sender;
        weth = swapRouter.WETH9();
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    function setWhitelist(address _newAddr) external isOwner {
        whitelist[_newAddr] = true;
    }

    function remoteWhitelist(address _address) external isOwner {
        whitelist[_address] = false;
    }

    function _unwrapWETH9(address _recipient)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory recipient = abi.encodePacked(_recipient);
        bytes32 _amountOutMinimum = bytes32(amountOutMinimum);
        return bytes.concat(unwrapWETHId, _amountOutMinimum, zero, recipient);
    }

    function getParams(address _tokenIn, address _tokenOut)
        internal
        view
        returns (bytes memory)
    {
        address recipient;

        if (_tokenOut == weth) {
            recipient = msg.sender;
        } else {
            recipient = address(this);
        }

        bytes memory tokenIn = abi.encodePacked(_tokenIn);
        bytes memory tokenOut = abi.encodePacked(_tokenOut);

        return
            bytes.concat(
                methodId,
                bytes32(IERC20(_tokenIn).balanceOf(address(this))),
                bytes32(amountOutMinimum),
                bytes32(arg1),
                zero,
                abi.encodePacked(recipient),
                bytes32(arg2),
                zero,
                tokenIn,
                zero,
                tokenOut
            );
    }

    function swapToken(address _tokenIn, address _tokenOut)
        external
        isWhitelist
    {
        require(
            IERC20(_tokenIn).balanceOf(address(this)) > 0,
            "No Token Balance to swap"
        );

        IERC20(_tokenIn).approve(
            address(swapRouter),
            IERC20(_tokenIn).balanceOf(address(this))
        );

        bytes[] memory data = new bytes[](2);
        bytes memory unwrapWETH9 = _unwrapWETH9(msg.sender);
        bytes memory _data = getParams(_tokenIn, _tokenOut);

        uint256 deadline = block.timestamp + 1000;

        data[0] = _data;
        data[1] = unwrapWETH9;

        swapRouter.multicall(deadline, data);
    }

    function deposit() external isOwner {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external isOwner {
        require(IWETH(weth).balanceOf(address(this)) > 0);
        IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    receive() external payable {}
}

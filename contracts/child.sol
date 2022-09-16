// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface ISwapRouter {
    function multicall(uint256 deadline, bytes[] memory data)
        external
        payable
        returns (bytes[] memory);

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

    uint256 public constant poolFee = 3000;

    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes4 private constant methodId = 0x04e45aaf;
    bytes4 private constant methodId1 = 0x472b43f3;
    bytes4 private constant unwrapWETHId = 0x49404b7c;
    uint256 public constant arg1 = 128;
    uint256 public constant arg2 = 2;
    uint256 public constant amountOutMinimum = 0;

    constructor(address _router) {
        swapRouter = ISwapRouter(_router);
        whitelist[msg.sender] = true;
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

    // function singleParams(
    //     address _tokenIn,
    //     address _tokenOut,
    //     address _recipient,
    //     uint256 _amount
    // ) internal pure returns (bytes memory) {
    //     bytes memory tokenIn = abi.encodePacked(_tokenIn);
    //     bytes memory tokenOut = abi.encodePacked(_tokenOut);
    //     bytes32 fee = bytes32(poolFee);
    //     bytes memory recipient = abi.encodePacked(_recipient);
    //     bytes32 amountIn = bytes32(_amount);
    //     bytes32 amountOutMinimum = bytes32(0);
    //     bytes32 sqrtPriceLimitX96 = bytes32(0);
    //     return
    //         bytes.concat(
    //             methodId,
    //             zero,
    //             tokenIn,
    //             zero,
    //             tokenOut,
    //             fee,
    //             zero,
    //             recipient,
    //             amountIn,
    //             amountOutMinimum,
    //             sqrtPriceLimitX96
    //         );
    // }

    function _refundETH() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("refundETH()");
    }

    function _unwrapWETH9(address _recipient)
        public
        pure
        returns (bytes memory)
    {
        bytes memory recipient = abi.encodePacked(_recipient);
        bytes32 _amountOutMinimum = bytes32(amountOutMinimum);
        return bytes.concat(unwrapWETHId, _amountOutMinimum, zero, recipient);
    }

    // function buyToken(address token) public payable isWhitelist {
    //     require(address(this).balance > 0, "No ETH Balance");
    //     bytes[] memory datas = new bytes[](2);
    //     uint256 deadline = block.timestamp + 1000;
    //     bytes memory data = singleParams(
    //         weth,
    //         token,
    //         address(this),
    //         address(this).balance
    //     );
    //     bytes memory refundETH = _refundETH();
    //     datas[0] = data;
    //     datas[1] = refundETH;
    //     swapRouter.multicall{value: address(this).balance}(deadline, datas);
    // }

    // function sellToken(address token) public isWhitelist {
    //     require(
    //         IERC20(token).balanceOf(address(this)) > 0,
    //         "No Token Balance to swap"
    //     );
    //     bytes[] memory datas = new bytes[](1);
    //     uint256 deadline = block.timestamp + 1000;
    //     IERC20(token).approve(
    //         address(swapRouter),
    //         IERC20(token).balanceOf(address(this))
    //     );
    //     bytes memory data = singleParams(
    //         token,
    //         weth,
    //         msg.sender,
    //         IERC20(token).balanceOf(address(this))
    //     );
    //     datas[0] = data;
    //     swapRouter.multicall(deadline, datas);
    // }

    function _singleParams(address _tokenOut)
        public
        view
        returns (bytes memory)
    {
        bytes memory tokenIn = abi.encodePacked(weth);
        bytes memory tokenOut = abi.encodePacked(_tokenOut);
        return
            bytes.concat(
                methodId1,
                bytes32(address(this).balance),
                bytes32(amountOutMinimum),
                bytes32(arg1),
                zero,
                abi.encodePacked(address(this)),
                bytes32(arg2),
                zero,
                tokenIn,
                zero,
                tokenOut
            );
    }

    function _sellParams(address _tokenIn) public view returns (bytes memory) {
        bytes memory tokenIn = abi.encodePacked(_tokenIn);
        bytes memory tokenOut = abi.encodePacked(weth);
        return
            bytes.concat(
                methodId1,
                bytes32(IERC20(_tokenIn).balanceOf(address(this))),
                bytes32(amountOutMinimum),
                bytes32(arg1),
                bytes32(arg2),
                bytes32(arg2),
                zero,
                tokenIn,
                zero,
                tokenOut
            );
    }

    function _buyToken(address _token) external payable {
        bytes[] memory data = new bytes[](2);
        bytes memory refundETH = _refundETH();
        bytes memory _data = _singleParams(_token);
        data[0] = _data;
        data[1] = refundETH;
        uint256 deadline = block.timestamp + 1000;
        swapRouter.multicall{value: address(this).balance}(deadline, data);
    }

    function _sellToken(address _token) external {
        require(
            IERC20(_token).balanceOf(address(this)) > 0,
            "No Token Balance to swap"
        );
        IERC20(_token).approve(
            address(swapRouter),
            IERC20(_token).balanceOf(address(this))
        );
        bytes[] memory data = new bytes[](2);
        bytes memory unwrapWETH9 = _unwrapWETH9(
            msg.sender
        );
        bytes memory _data = _sellParams(_token);
        uint256 deadline = block.timestamp + 1000;
        data[0] = _data;
        data[1] = unwrapWETH9;
        swapRouter.multicall(deadline, data);
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

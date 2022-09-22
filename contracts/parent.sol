// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IChild {
    function swapToken(address tokenIn, address tokenOut, uint256 percent) external;
}

interface IERC20 {
    function deposit() external payable;

    function withdraw(uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

contract Parent {
    
    IUniswapV2Router02 public router;

    address public  owner;
    address[] public children;
    address public weth;
    uint256 public constant percentForBuy = 100;
    mapping(address => bool) whitelist;


    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not whitelist");
        _;
    }

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        owner = msg.sender;
        whitelist[msg.sender] = true;
        weth = router.WETH();
    }

    function setWhitelist(address[] calldata _whitelist) external isOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata _blacklist) external isOwner {
        for (uint256 i = 0; i < _blacklist.length; i++) {
            whitelist[_blacklist[i]] = false;
        }
    }

    function setOwner(address _owner) external isOwner {
        owner = _owner;
    }

    function setWeth(address _weth) external isOwner {
        weth = _weth;
    }

    function addChildren(address[] calldata _childContracts) external isOwner {
        for (uint256 i = 0; i < _childContracts.length; i++) {
            children.push(_childContracts[i]);
        }
    }

    function multiBuyToken(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountPerChild,
        uint256[] calldata idxs
    ) external isWhitelist {
        uint256 tokenBalance = IERC20(tokenIn).balanceOf(address(this));
        require(tokenBalance > amountPerChild, "Invalid input amount");
        
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }

        uint256 cnt;
        if(amountIn > tokenBalance)
            amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if(cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt; i++) {
            IERC20(tokenIn).transfer(children[idxs[i]], amountPerChild);
            IChild(children[idxs[i]]).swapToken(tokenIn, tokenOut, percentForBuy);
            amountIn -= amountPerChild;
        }

        IERC20(tokenIn).transfer(children[idxs[cnt]], amountIn);
        IChild(children[idxs[cnt]]).swapToken(tokenIn, tokenOut, percentForBuy);
    }

    function multiBuyTokenForExactAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        uint256[] calldata idxs
    ) external isWhitelist {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        uint256 amountPerChild = _getAmuntsIn(amountOut, path);

        uint256 tokenBalance = IERC20(tokenIn).balanceOf(address(this));
        require(tokenBalance > amountPerChild, "Invalid input amount");

        uint256 cnt;
        if(amountIn > tokenBalance)
            amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if(cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt; i++) {
            IERC20(tokenIn).transfer(children[idxs[i]], amountPerChild);
            IChild(children[idxs[i]]).swapToken(tokenIn, tokenOut, percentForBuy);
            amountIn -= amountPerChild;
        }
        
        IERC20(tokenIn).transfer(children[idxs[cnt]], amountIn);
        IChild(children[idxs[cnt]]).swapToken(tokenIn, tokenOut, percentForBuy);
    }

    function multiSellToken(
        address tokenIn, 
        address tokenOut, 
        uint256[] calldata idxs,
        uint256 percent
    ) 
        external 
        isWhitelist 
    {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }
        for(uint256 i = 0; i < idxs.length; i ++) {
            IChild(children[idxs[i]]).swapToken(tokenIn, tokenOut, percent);
        }
    }

    function deposit() external isOwner {
        require(address(this).balance > 0, "No Eth Balance");
        IERC20(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external isOwner {
        if (IERC20(weth).balanceOf(address(this)) > 0) {
            IERC20(weth).withdraw(IERC20(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    receive() external payable {}

    function _getAmuntsIn(uint256 amountOut, address[] memory path) internal view returns(uint256 amountIn) {
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);
        require(amounts[0] > 0, "No liquidity pool");
        amountIn = amounts[0];
    }
}

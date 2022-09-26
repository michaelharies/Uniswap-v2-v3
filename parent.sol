// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IChild {
    function swapToken(address[] memory path, uint256 percent, bool flag) external;
    function unLock() external;
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

    address public owner;
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

    function setWhitelist(address[] calldata _whitelist) 
        external 
        isOwner 
    {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata _blacklist) 
        external 
        isOwner 
    {
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

    function addChildren(address[] calldata _childContracts) 
        external 
        isOwner 
    {
        for (uint256 i = 0; i < _childContracts.length; i++) {
            children.push(_childContracts[i]);
        }
    }

    function multiBuyToken(
        address[] memory path,
        uint256 amountIn,
        uint256 amountPerChild,
        uint256[] calldata idxs
    ) 
        external 
        isWhitelist 
    {
        require(path.length < 3, "Exceed path");
        uint256 tokenBalance = IERC20(weth).balanceOf(address(this));
        require(tokenBalance > amountPerChild, "Invalid input amount for Child");

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }

        uint256 cnt;
        if (amountIn > tokenBalance) amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if (cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt-1; i++) {
            IERC20(weth).transfer(children[idxs[i]], amountPerChild);
            IChild(children[idxs[i]]).swapToken(path, percentForBuy, true);
            amountIn -= amountPerChild;
        }

        IERC20(weth).transfer(children[idxs[cnt-1]], amountIn);
        IChild(children[idxs[cnt-1]]).swapToken(path, percentForBuy, true);
    }

    function multiBuyTokenForExactAmountOut(
        address[] memory path,
        uint256 amountIn,
        uint256 amountOut,
        uint256[] calldata idxs
    ) 
        external 
        isWhitelist 
    {
        require(path.length < 3, "Exceed path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }
        uint256 amountPerChild = _getAmuntsIn(amountOut, path);

        uint256 tokenBalance = IERC20(weth).balanceOf(address(this));
        require(tokenBalance > amountPerChild, "Invalid input amount");

        uint256 cnt;
        if (amountIn > tokenBalance) amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if (cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt-1 ; i++) {
            IERC20(weth).transfer(children[idxs[i]], amountPerChild);
            IChild(children[idxs[i]]).swapToken(path, percentForBuy, true);
            amountIn -= amountPerChild;
        }

        IERC20(weth).transfer(children[idxs[cnt-1]], amountIn);
        IChild(children[idxs[cnt-1]]).swapToken(path, percentForBuy,true);
    }

    function multiSellToken(
        address[] memory path,
        uint256[] calldata idxs,
        uint256 percent
    ) 
        external 
        isWhitelist 
    {
        require(path.length == 2, "Exceed path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(children[idxs[i]]).swapToken(path, percent, false);
        }
    }

    function deposit() 
        external 
        isOwner 
    {
        require(address(this).balance > 0, "No Eth Balance");
        IERC20(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() 
        external 
        isOwner 
    {
        if (IERC20(weth).balanceOf(address(this)) > 0) {
            IERC20(weth).withdraw(IERC20(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address _address) 
        external 
        isOwner 
    {
        require(IERC20(_address).balanceOf(address(this)) > 0);
        IERC20(_address).transfer(
            msg.sender,
            IERC20(_address).balanceOf(address(this))
        );
    }

    function getEthBalance() 
        external 
        view 
        returns(uint256) 
    {
        return address(this).balance;
    }

    function getBalance(address token) 
        external 
        view 
        returns(uint256) 
    {
        return IERC20(token).balanceOf(address(this));
    }

    receive() external payable {}

    function unLockChild(uint256[] memory idxs) 
        external 
        isOwner 
    {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < children.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(children[idxs[i]]).unLock();
        }
    }

    function _getAmuntsIn(uint256 amountOut, address[] memory path)
        internal
        view
        returns (uint256 amountIn)
    {
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);
        require(amounts[0] > 0, "No liquidity pool");
        amountIn = amounts[0];
    }
}

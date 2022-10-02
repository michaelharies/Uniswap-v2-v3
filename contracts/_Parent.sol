// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "./Test_Child.sol";

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/Parent.sol

pragma solidity ^0.8.7;

interface IChild {
    function swapTokenV2(
        address[] memory path,
        uint256 percent,
        uint256 amountOut
    ) external;

    function swapTokenV3(address[] memory path, uint256 percent) external;

    function withdrawEth() external;

    function withdrawToken(address to, address token) external;

    function unLock(address token) external;

    function getParamsForV2(
        address[] memory _path,
        uint256 _percent,
        bool _flag
    ) external view returns (bytes memory);

    function getExactInputParam(address[] memory _path, uint256 amountIn)
        external
        view
        returns (bytes memory);

    function getExactInputSingleParam(address[] memory _path, uint256 amountIn)
        external
        view
        returns (bytes memory);
}

contract Test_Parent is Ownable {
    IUniswapV2Router02 public router;
    address public implementation;
    address[] public childContracts;
    address public weth;
    uint256 public constant wholeAmount = 100;
    uint256 public constant amuntOut = 1000;
    mapping(address => bool) whitelist;

    event ChildContract(address _clonedContract);

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        whitelist[msg.sender] = true;
        weth = router.WETH();
    }

    function Ellzhd(address _impl, uint256 cnt) public onlyOwner {
        implementation = _impl;
        for (uint256 i = 0; i < cnt; i++) {
            address payable clone = createClone(implementation);
            childContracts.push(clone);
            Child(clone).approveWeth();
            emit ChildContract(clone);
        }
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not whitelist");
        _;
    }

    function addBulkWhitelists(address[] calldata _whitelist) external {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata _blacklist) external {
        for (uint256 i = 0; i < _blacklist.length; i++) {
            whitelist[_blacklist[i]] = false;
        }
    }

    function buyTokenV2(
        address[] memory path,
        uint256 amountIn,
        uint256[] calldata idxs,
        uint256 _amountOut
    ) external {
        require(path.length == 2 || path.length == 3, "Exceed path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(amountIn < tokenBalance, "Invalid amount value");

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        uint256 amountPerChild = amountIn / idxs.length;

        for (uint256 i = 0; i < idxs.length; i++) {
            IWETH(weth).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapTokenV2(
                path,
                wholeAmount,
                _amountOut
            );
        }
    }

    function buyTokenForExactAmountOutV2(
        address[] calldata path,
        uint256 amountIn,
        uint256 amountOut,
        uint256[] calldata idxs
    ) external {
        require(path.length == 2 || path.length == 3, "Invalid path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(amountIn < tokenBalance, "Invalid amount value");

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        uint256 amountToBuy = _getAmuntsIn(amountOut, path);
        uint256 amountPerChild = amountIn / amountToBuy;

        for (uint256 i = 0; i < idxs.length; i++) {
            IWETH(weth).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapTokenV2(
                path,
                wholeAmount,
                amountOut
            );
            amountIn -= amountPerChild;
        }
    }

    function multiSellTokenV2(
        address[] calldata path,
        uint256[] calldata idxs,
        uint256 percent,
        uint256 _amountOut
    ) external {
        require(path.length == 2 || path.length == 3, "Invalid path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).swapTokenV2(path, percent, _amountOut);
        }
    }

    function sellAllTokens(address[] calldata path) external {
        require(path.length == 2 || path.length == 3, "Invalid path");
        for (uint256 i = 0; i < childContracts.length; i++) {
            IChild(childContracts[i]).swapTokenV2(path, wholeAmount, amuntOut);
        }
    }

    function swapTokenV3(
        address[] memory path,
        uint256 amountIn,
        uint256[] calldata idxs
    ) external {
        require(path.length == 2 || path.length == 3, "Exceed path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(amountIn < tokenBalance, "Invalid amount value");

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        uint256 amountPerChild = amountIn / idxs.length;

        for (uint256 i = 0; i < idxs.length; i++) {
            IWETH(weth).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapTokenV3(path, wholeAmount);
        }
    }

    function deposit() external {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address _address) external {
        require(IWETH(_address).balanceOf(address(this)) > 0);
        IWETH(_address).transfer(
            msg.sender,
            IWETH(_address).balanceOf(address(this))
        );
    }

    function withdrawEthFromChild(uint256 childID) external {
        IChild(childContracts[childID]).withdrawEth();
    }

    function withdrawTokenFromChild(
        uint256 childID,
        address _to,
        address _token
    ) external {
        IChild(childContracts[childID]).withdrawToken(_to, _token);
    }

    function unLockChild(uint256[] calldata idxs, address token) public {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).unLock(token);
        }
    }

    function _getAmuntsIn(uint256 amountOut, address[] calldata _path)
        internal
        view
        returns (uint256 amountIn)
    {
        address[] memory newPath = new address[](2);
        newPath[0] = _path[0];
        newPath[1] = _path[1];

        uint256[] memory amounts = router.getAmountsIn(amountOut, newPath);
        require(amounts[0] > 0, "No liquidity pool");
        amountIn = amounts[0];
    }

    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address token) external view returns (uint256) {
        return IWETH(token).balanceOf(address(this));
    }

    function getEllzhd() external view returns (address[] memory) {
        return childContracts;
    }

    function getEllzhdETHBalance(uint256 childID)
        external
        view
        returns (address, uint256)
    {
        address child = childContracts[childID];
        uint256 balance = child.balance;
        return (child, balance);
    }

    function getEllzhdTokenBalance(uint256 childID, address token)
        external
        view
        returns (address, uint256)
    {
        address child = childContracts[childID];
        uint256 balance = IWETH(token).balanceOf(child);
        return (child, balance);
    }

    receive() external payable {}

    fallback() external payable {}

    function createClone(address target)
        internal
        returns (address payable result)
    {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function checkUnlock(uint256 idx, address token)
        external
        view
        returns (bool)
    {}

    function getParaFromChildV2(
        uint256 idx,
        address[] memory _path,
        uint256 _percent,
        bool _flag
    ) external view returns (bytes memory data) {
        data = IChild(childContracts[idx]).getParamsForV2(
            _path,
            _percent,
            _flag
        );
    }

    function getParaFromChildV3(
        uint256 idx,
        address[] memory _path,
        uint256 amount,
        bool flag
    ) external view returns (bytes memory data) {
        if (flag) {
            data = IChild(childContracts[idx]).getExactInputParam(
                _path,
                amount
            );
        } else {
            data = IChild(childContracts[idx]).getExactInputSingleParam(
                _path,
                amount
            );
        }
    }
}

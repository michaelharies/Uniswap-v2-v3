// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "./Child.sol";

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

interface IChild {
    function swapExactTokenForToken(address[] memory path, uint256 percent)
        external;

    function swapTokenForExactToken(address[] memory path, uint256 amountOut)
        external;

    function withdrawEth() external;

    function withdrawToken(address to, address token) external;

    function unLock(address token) external;
}

contract Parent is Ownable {
    IUniswapV2Router02 public routerV2;
    address public factoryV2 = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public factoryV3 = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    IQuoter public constant quoterV3 =
        IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    address public implementation;
    address[] public childContracts;
    address public weth;
    uint256 public constant wholeAmount = 100;
    uint256 public constant amuntOut = 1000;
    uint24 public constant poolFee = 3000;
    mapping(address => bool) whitelist;

    event ChildContract(address _clonedContract);

    constructor() {
        routerV2 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        whitelist[msg.sender] = true;
        weth = routerV2.WETH();
    }

    function Ellzhd(address _impl, uint256 cnt) public onlyOwner {
        implementation = _impl;
        for (uint256 i = 0; i < cnt; i++) {
            address payable clone = createClone(implementation);
            childContracts.push(clone);
            Child(clone).init();
            emit ChildContract(clone);
        }
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not whitelist");
        _;
    }

    function addBulkWhitelists(address[] calldata _whitelist)
        external
        isWhitelist
    {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata _blacklist)
        external
        isWhitelist
    {
        for (uint256 i = 0; i < _blacklist.length; i++) {
            whitelist[_blacklist[i]] = false;
        }
    }

    function swapExactTokenForToken(
        address[] calldata path,
        uint256 amountIn,
        uint256[] calldata idxs,
        uint256 percent
    ) external isWhitelist {
        require(path.length == 2 || path.length == 3, "Exceed path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(amountIn < tokenBalance, "Invalid amount value");

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        uint256 amountPerChild = amountIn / idxs.length;

        for (uint256 i = 0; i < idxs.length; i++) {
            IWETH(path[0]).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapExactTokenForToken(
                path,
                percent
            );
        }
    }

    function swapTokenForExactToken(
        address[] calldata path,
        uint256 amountIn,
        uint256 amountOut,
        uint256[] calldata idxs
    ) external isWhitelist {
        require(path.length == 2 || path.length == 3, "Invalid path");
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this));
        require(tokenBalance >= amountIn, "Invalid amount value");
        uint256 amountPerChild;

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        (uint256 amount0, uint256 amount1) = checkUniswapV2Pair(path);
        if (amount0 > 0 && amount1 > 0) {
            uint256 amountInForToken = _getAmountsIn(amountOut, path);
            if (amountInForToken > 0) {
                amountPerChild = amountInForToken;
                require(
                    amountIn >= amountPerChild * idxs.length,
                    "Transfer amount exceeds balance, Amount & AmountOut"
                );
            } else {
                amountPerChild = _getParamForV3(path, amountOut);
                require(
                    amountIn >= amountPerChild * idxs.length,
                    "Transfer amount exceeds balance, Amount & AmountOut"
                );
            }
        } else {
            amountPerChild = _getParamForV3(path, amountOut);
            require(
                amountIn >= amountPerChild * idxs.length,
                "Transfer amount exceeds balance, Amount & AmountOut"
            );
        }

        for (uint256 i = 0; i < idxs.length; i++) {
            IWETH(path[0]).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapTokenForExactToken(
                path,
                amountPerChild
            );
        }
    }

    function multiSellTokenV2(
        address[] calldata path,
        uint256[] calldata idxs,
        uint256 percent
    ) external isWhitelist {
        require(path.length == 2 || path.length == 3, "Invalid path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).swapExactTokenForToken(
                path,
                percent
            );
        }
    }

    function sellAllTokens(address[] calldata path, uint256 percent)
        external
        isWhitelist
    {
        require(path.length == 2 || path.length == 3, "Invalid path");
        for (uint256 i = 0; i < childContracts.length; i++) {
            IChild(childContracts[i]).swapExactTokenForToken(path, percent);
        }
    }

    function deposit() external isWhitelist {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external isWhitelist {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address token, address to) external isWhitelist {
        require(IWETH(token).balanceOf(address(this)) > 0);
        IWETH(token).transfer(to, IWETH(token).balanceOf(address(this)));
    }

    function withdrawEthFromChild(uint256 childID) external isWhitelist {
        IChild(childContracts[childID]).withdrawEth();
    }

    function withdrawTokenFromChild(
        uint256 childID,
        address _to,
        address _token
    ) external isWhitelist {
        IChild(childContracts[childID]).withdrawToken(_to, _token);
    }

    function unLockChild(uint256[] calldata idxs, address token)
        external
        isWhitelist
    {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).unLock(token);
        }
    }

    function checkUniswapV2Pair(address[] calldata _path)
        internal
        view
        returns (uint256 _amount0, uint256 _amount1)
    {
        address pair = IUniswapV2Factory(factoryV2).getPair(_path[0], _path[1]);
        _amount0 = IWETH(_path[0]).balanceOf(pair);
        _amount1 = IWETH(_path[1]).balanceOf(pair);
    }

    function _getAmountsIn(uint256 amountOut, address[] calldata _path)
        internal
        view
        returns (uint256 _amountIn)
    {
        uint256[] memory amounts = routerV2.getAmountsIn(amountOut, _path);
        _amountIn = amounts[0];
    }

    function _getParamForV3(address[] calldata _path, uint256 _amountOut)
        internal
        returns (uint256 _amountIn)
    {
        if (_path.length == 2) {
            address pool = IUniswapV3Factory(factoryV3).getPool(
                _path[0],
                _path[1],
                poolFee
            );
            uint256 poolAmount0 = IWETH(_path[0]).balanceOf(pool);
            uint256 poolAmount1 = IWETH(_path[1]).balanceOf(pool);
            if (poolAmount0 > 0 && poolAmount1 > 0) {
                _amountIn = quoterV3.quoteExactOutputSingle(
                    _path[0],
                    _path[1],
                    poolFee,
                    _amountOut,
                    0
                );
            }
        } else {
            bytes memory quoterPath = abi.encodePacked(
                _path[0],
                poolFee,
                _path[1],
                poolFee,
                _path[2]
            );
            _amountIn = quoterV3.quoteExactOutput(quoterPath, _amountOut);
        }
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
}

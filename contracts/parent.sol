// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Child.sol";

interface IChild {
    function swapToken(
        address[] memory path,
        uint256 percent,
        bool flag
    ) external;

    function withdrawToken(address to, address token) external;

    function unLock() external;

    function test1() external view returns(address, address, address);
    function test2() external view returns(address, address, address);
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

contract Parent is Ownable {
    IUniswapV2Router02 public router;
    address public implementation;
    address[] public childContracts;
    address public weth;
    uint256 public constant percentForBuy = 100;
    mapping(address => bool) whitelist;

    event ChildContract(address _clonedContract);

    constructor() {
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        whitelist[msg.sender] = true;
        weth = router.WETH();
    }

    function Ellzhd(address _impl, uint256 cnt) 
        public 
        onlyOwner
    {
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

    function addBulkWhitelists(address[] calldata _whitelist)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] calldata _blacklist) external onlyOwner {
        for (uint256 i = 0; i < _blacklist.length; i++) {
            whitelist[_blacklist[i]] = false;
        }
    }

    function multiBuyToken(
        address[] memory path,
        uint256 amountIn,
        uint256 amountPerChild,
        uint256[] calldata idxs
    ) external isWhitelist {
        require(path.length < 3, "Exceed path");
        uint256 tokenBalance = IWETH(weth).balanceOf(address(this));
        require(
            tokenBalance > amountPerChild,
            "Invalid input amount for Child"
        );

        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }

        uint256 cnt;
        if (amountIn > tokenBalance) amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if (cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt - 1; i++) {
            IWETH(weth).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapToken(
                path,
                percentForBuy,
                true
            );
            amountIn -= amountPerChild;
        }

        IWETH(weth).transfer(childContracts[idxs[cnt - 1]], amountIn);
        IChild(childContracts[idxs[cnt - 1]]).swapToken(
            path,
            percentForBuy,
            true
        );
    }

    function multiBuyTokenForExactAmountOut(
        address[] calldata path,
        uint256 amountIn,
        uint256 amountOut,
        uint256[] calldata idxs
    ) external isWhitelist {
        require(path.length < 3, "Exceed path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        uint256 amountPerChild = _getAmuntsIn(amountOut, path);

        uint256 tokenBalance = IWETH(weth).balanceOf(address(this));
        require(tokenBalance > amountPerChild, "Invalid input amount");

        uint256 cnt;
        if (amountIn > tokenBalance) amountIn = tokenBalance;
        cnt = amountIn / amountPerChild;
        if (cnt > idxs.length) cnt = idxs.length;

        for (uint256 i = 0; i < cnt - 1; i++) {
            IWETH(weth).transfer(childContracts[idxs[i]], amountPerChild);
            IChild(childContracts[idxs[i]]).swapToken(
                path,
                percentForBuy,
                true
            );
            amountIn -= amountPerChild;
        }

        IWETH(weth).transfer(childContracts[idxs[cnt - 1]], amountIn);
        IChild(childContracts[idxs[cnt - 1]]).swapToken(
            path,
            percentForBuy,
            true
        );
    }

    function multiSellToken(
        address[] calldata path,
        uint256[] calldata idxs,
        uint256 percent
    ) external isWhitelist {
        require(path.length == 2, "Exceed path");
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).swapToken(path, percent, false);
        }
    }

    function deposit() external onlyOwner {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external onlyOwner {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address _address) external onlyOwner {
        require(IWETH(_address).balanceOf(address(this)) > 0);
        IWETH(_address).transfer(
            msg.sender,
            IWETH(_address).balanceOf(address(this))
        );
    }

    function withdrawTokenFromChild(
        uint256 childID,
        address _to,
        address _token
    ) external onlyOwner {
        address child = childContracts[childID];
        IChild(child).withdrawToken(_to, _token);
    }

    function unLockChild(uint256[] calldata idxs) public onlyOwner {
        for (uint256 i = 0; i < idxs.length; i++) {
            require(idxs[i] < childContracts.length, "Exceed array index");
        }
        for (uint256 i = 0; i < idxs.length; i++) {
            IChild(childContracts[idxs[i]]).unLock();
        }
    }

    function _getAmuntsIn(uint256 amountOut, address[] calldata path)
        internal
        view
        returns (uint256 amountIn)
    {
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);
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

    function createClone(address target) internal returns (address payable result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }

    function getTestData1(uint256 idx) external view returns(address result, address result1, address result2) {
        (result, result1, result2) = IChild(childContracts[idx]).test1();
    }

    function getTestData2(uint256 idx) external view returns(address result, address result1, address result2) {
        (result, result1, result2) = IChild(childContracts[idx]).test2();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
	/**
		* @dev Returns the amount of tokens in existence.
		*/
	function totalSupply() external view returns (uint256);

	/**
		* @dev Returns the amount of tokens owned by `account`.
		*/
	function balanceOf(address account) external view returns (uint256);

	/**
		* @dev Moves `amount` tokens from the caller's account to `recipient`.
		*
		* Returns a boolean value indicating whether the operation succeeded.
		*
		* Emits a {Transfer} event.
		*/
	function transfer(address recipient, uint256 amount)
			external
			returns (bool);

	/**
		* @dev Returns the remaining number of tokens that `spender` will be
		* allowed to spend on behalf of `owner` through {transferFrom}. This is
		* zero by default.
		*
		* This value changes when {approve} or {transferFrom} are called.
		*/
	function allowance(address owner, address spender)
			external
			view
			returns (uint256);

	/**
		* @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
		*
		* Returns a boolean value indicating whether the operation succeeded.
		*
		* IMPORTANT: Beware that changing an allowance with this method brings the risk
		* that someone may use both the old and the new allowance by unfortunate
		* transaction ordering. One possible solution to mitigate this race
		* condition is to first reduce the spender's allowance to 0 and set the
		* desired value afterwards:
		* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		*
		* Emits an {Approval} event.
		*/
	function approve(address spender, uint256 amount) external returns (bool);

	/**
		* @dev Moves `amount` tokens from `sender` to `recipient` using the
		* allowance mechanism. `amount` is then deducted from the caller's
		* allowance.
		*
		* Returns a boolean value indicating whether the operation succeeded.
		*
		* Emits a {Transfer} event.
		*/
	function transferFrom(
			address sender,
			address recipient,
			uint256 amount
	) external returns (bool);

	/**
		* @dev Emitted when `value` tokens are moved from one account (`from`) to
		* another (`to`).
		*
		* Note that `value` may be zero.
		*/
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
		* @dev Emitted when the allowance of a `spender` for an `owner` is set by
		* a call to {approve}. `value` is the new allowance.
		*/
	event Approval(
			address indexed owner,
			address indexed spender,
			uint256 value
	);
}

interface IChild {
    function swapExactETHForTokens(address token, uint256 amountIn)
        external
        returns (uint256 amountOut);

    function swapExactInputSingle(address token)
        external
        returns (uint256 amountOut);
}

contract Parent {
    address public owner;
    mapping(address => bool) whitelist;
    address[] public childContracts;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not whitelist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setWhitelist(address[] memory _whitelist) public isOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            whitelist[_whitelist[i]] = true;
        }
    }

    function removeWhitelist(address[] memory _blacklist) public isOwner {
        for (uint256 i = 0; i < _blacklist.length; i++) {
            whitelist[_blacklist[i]] = false;
        }
    }

    function setOwner(address _owner) public isOwner {
        owner = _owner;
    }

    function addchildContract(address[] memory _childContracts) public isOwner {
        for (uint256 i = 0; i < _childContracts.length; i++) {
            childContracts.push(_childContracts[i]);
        }
    }

    function buyToken(
        address token,
        uint256 amountIn,
        uint256[] memory childAddr,
        uint256 amountPerChild
    ) public payable isWhitelist {
        require(address(this).balance >= amountIn, "Insufficient Eth to buy");
        for (uint256 i = 0; i < childAddr.length; i++) {
            (bool sent, ) = childContracts[childAddr[i]].call{
                value: amountPerChild
            }("");
            require(sent, "Failed to send Ether");
            IChild(childContracts[childAddr[i]]).swapExactETHForTokens(
                token,
                amountPerChild
            );
            amountIn -= amountPerChild;
        }
        (bool sentRemainAmount, ) = childContracts[childAddr.length].call{
            value: amountIn
        }("");
        require(sentRemainAmount, "Failed to send Ether");
        IChild(childContracts[childAddr[childAddr.length]])
            .swapExactETHForTokens(token, amountIn);
    }

    function sellToken(address token) public isWhitelist {
        for (uint256 i = 0; i < childContracts.length; i++) {
            IChild(childContracts[i]).swapExactInputSingle(token);
        }
    }

    function withdrawEth() external isOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }
}

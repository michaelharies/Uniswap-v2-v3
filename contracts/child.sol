// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

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

contract Child {
    IUniswapV2Router02 public router;
    ISwapRouter public immutable swapRouter;

    address public owner;
    address public weth;
    address private routerAddr;
    mapping(address => bool) private whitelist;

    uint24 public constant poolFee = 3000;

    constructor(
        ISwapRouter _swapRouter,
        address _router,
        address _mainContract
    ) {
        router = IUniswapV2Router02(_router);
        weth = router.WETH();
        swapRouter = _swapRouter;
        whitelist[_mainContract] = true;
        routerAddr = _router;
        owner = msg.sender;
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

    //buy use V2
    function swapExactETHForTokens(address _token, uint256 _amountIn)
        external
        payable
        isWhitelist
    {
        require(address(this).balance >= _amountIn, "Insufficient Eth");
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = _token;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amountIn
        }(0, path, address(this), block.timestamp);
    }

    //Sell use V3
    function swapExactInputSingle(address token)
        external
        isWhitelist
        returns (uint256 amountOut)
    {
        require(
            IERC20(token).balanceOf(address(this)) >= 0,
            "Insufficient Token"
        );

        TransferHelper.safeApprove(
            token,
            address(swapRouter),
            IERC20(token).balanceOf(address(this))
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: token,
                tokenOut: weth,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: IERC20(token).balanceOf(address(this)),
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    receive() external payable {}
}

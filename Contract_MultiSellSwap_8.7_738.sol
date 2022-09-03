// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

interface IUniswapV2Pair {
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external pure returns (string memory);

	function symbol() external pure returns (string memory);

	function decimals() external pure returns (uint8);

	function totalSupply() external view returns (uint256);

	function balanceOf(address owner) external view returns (uint256);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 value) external returns (bool);

	function transfer(address to, uint256 value) external returns (bool);

	function transferFrom(address from, address to, uint256 value) external returns (bool);

	function DOMAIN_SEPARATOR() external view returns (bytes32);

	function PERMIT_TYPEHASH() external pure returns (bytes32);

	function nonces(address owner) external view returns (uint256);

	function permit(
			address owner,
			address spender,
			uint256 value,
			uint256 deadline,
			uint8 v,
			bytes32 r,
			bytes32 s
	) external;

	event Mint(address indexed sender, uint256 amount0, uint256 amount1);
	event Burn(
			address indexed sender,
			uint256 amount0,
			uint256 amount1,
			address indexed to
	);
	event Swap(
			address indexed sender,
			uint256 amount0In,
			uint256 amount1In,
			uint256 amount0Out,
			uint256 amount1Out,
			address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns (uint256);

	function factory() external view returns (address);

	function token0() external view returns (address);

	function token1() external view returns (address);

	function getReserves()
			external
			view
			returns (
					uint112 reserve0,
					uint112 reserve1,
					uint32 blockTimestampLast
			);

	function price0CumulativeLast() external view returns (uint256);

	function price1CumulativeLast() external view returns (uint256);

	function kLast() external view returns (uint256);

	function mint(address to) external returns (uint256 liquidity);

	function burn(address to)
			external
			returns (uint256 amount0, uint256 amount1);

	function swap(
			uint256 amount0Out,
			uint256 amount1Out,
			address to,
			bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

interface IUniswapV2Router01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
			address tokenA,
			address tokenB,
			uint256 amountADesired,
			uint256 amountBDesired,
			uint256 amountAMin,
			uint256 amountBMin,
			address to,
			uint256 deadline
	)
			external
			returns (
					uint256 amountA,
					uint256 amountB,
					uint256 liquidity
			);

	function addLiquidityETH(
			address token,
			uint256 amountTokenDesired,
			uint256 amountTokenMin,
			uint256 amountETHMin,
			address to,
			uint256 deadline
	)
			external
			payable
			returns (
					uint256 amountToken,
					uint256 amountETH,
					uint256 liquidity
			);

	function removeLiquidity(
			address tokenA,
			address tokenB,
			uint256 liquidity,
			uint256 amountAMin,
			uint256 amountBMin,
			address to,
			uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
			address token,
			uint256 liquidity,
			uint256 amountTokenMin,
			uint256 amountETHMin,
			address to,
			uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
			address tokenA,
			address tokenB,
			uint256 liquidity,
			uint256 amountAMin,
			uint256 amountBMin,
			address to,
			uint256 deadline,
			bool approveMax,
			uint8 v,
			bytes32 r,
			bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
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
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
			uint256 amountIn,
			uint256 amountOutMin,
			address[] calldata path,
			address to,
			uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
			uint256 amountOut,
			uint256 amountInMax,
			address[] calldata path,
			address to,
			uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
			uint256 amountOutMin,
			address[] calldata path,
			address to,
			uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
			uint256 amountOut,
			uint256 amountInMax,
			address[] calldata path,
			address to,
			uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
			uint256 amountIn,
			uint256 amountOutMin,
			address[] calldata path,
			address to,
			uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
			uint256 amountOut,
			address[] calldata path,
			address to,
			uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
			uint256 amountA,
			uint256 reserveA,
			uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
			uint256 amountIn,
			uint256 reserveIn,
			uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
			uint256 amountOut,
			uint256 reserveIn,
			uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
			external
			view
			returns (uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path)
			external
			view
			returns (uint256[] memory amounts);
}

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

library SafeMath {
	/**
		* @dev Returns the addition of two unsigned integers, with an overflow flag.
		*
		* _Available since v3.4._
		*/
	function tryAdd(uint256 a, uint256 b)
			internal
			pure
			returns (bool, uint256)
	{
			uint256 c = a + b;
			if (c < a) return (false, 0);
			return (true, c);
	}

	/**
		* @dev Returns the substraction of two unsigned integers, with an overflow flag.
		*
		* _Available since v3.4._
		*/
	function trySub(uint256 a, uint256 b)
			internal
			pure
			returns (bool, uint256)
	{
			if (b > a) return (false, 0);
			return (true, a - b);
	}

	/**
		* @dev Returns the multiplication of two unsigned integers, with an overflow flag.
		*
		* _Available since v3.4._
		*/
	function tryMul(uint256 a, uint256 b)
			internal
			pure
			returns (bool, uint256)
	{
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) return (true, 0);
			uint256 c = a * b;
			if (c / a != b) return (false, 0);
			return (true, c);
	}

	/**
		* @dev Returns the division of two unsigned integers, with a division by zero flag.
		*
		* _Available since v3.4._
		*/
	function tryDiv(uint256 a, uint256 b)
			internal
			pure
			returns (bool, uint256)
	{
			if (b == 0) return (false, 0);
			return (true, a / b);
	}

	/**
		* @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
		*
		* _Available since v3.4._
		*/
	function tryMod(uint256 a, uint256 b)
			internal
			pure
			returns (bool, uint256)
	{
			if (b == 0) return (false, 0);
			return (true, a % b);
	}

	/**
		* @dev Returns the addition of two unsigned integers, reverting on
		* overflow.
		*
		* Counterpart to Solidity's `+` operator.
		*
		* Requirements:
		*
		* - Addition cannot overflow.
		*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
			uint256 c = a + b;
			require(c >= a, "SafeMath: addition overflow");
			return c;
	}

	/**
		* @dev Returns the subtraction of two unsigned integers, reverting on
		* overflow (when the result is negative).
		*
		* Counterpart to Solidity's `-` operator.
		*
		* Requirements:
		*
		* - Subtraction cannot overflow.
		*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
			require(b <= a, "SafeMath: subtraction overflow");
			return a - b;
	}

	/**
		* @dev Returns the multiplication of two unsigned integers, reverting on
		* overflow.
		*
		* Counterpart to Solidity's `*` operator.
		*
		* Requirements:
		*
		* - Multiplication cannot overflow.
		*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
			if (a == 0) return 0;
			uint256 c = a * b;
			require(c / a == b, "SafeMath: multiplication overflow");
			return c;
	}

	/**
		* @dev Returns the integer division of two unsigned integers, reverting on
		* division by zero. The result is rounded towards zero.
		*
		* Counterpart to Solidity's `/` operator. Note: this function uses a
		* `revert` opcode (which leaves remaining gas untouched) while Solidity
		* uses an invalid opcode to revert (consuming all remaining gas).
		*
		* Requirements:
		*
		* - The divisor cannot be zero.
		*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
			require(b > 0, "SafeMath: division by zero");
			return a / b;
	}

	/**
		* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
		* reverting when dividing by zero.
		*
		* Counterpart to Solidity's `%` operator. This function uses a `revert`
		* opcode (which leaves remaining gas untouched) while Solidity uses an
		* invalid opcode to revert (consuming all remaining gas).
		*
		* Requirements:
		*
		* - The divisor cannot be zero.
		*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
			require(b > 0, "SafeMath: modulo by zero");
			return a % b;
	}

	/**
		* @dev Returns the subtraction of two unsigned integers, reverting with custom message on
		* overflow (when the result is negative).
		*
		* CAUTION: This function is deprecated because it requires allocating memory for the error
		* message unnecessarily. For custom revert reasons use {trySub}.
		*
		* Counterpart to Solidity's `-` operator.
		*
		* Requirements:
		*
		* - Subtraction cannot overflow.
		*/
	function sub(
			uint256 a,
			uint256 b,
			string memory errorMessage
	) internal pure returns (uint256) {
			require(b <= a, errorMessage);
			return a - b;
	}

	/**
		* @dev Returns the integer division of two unsigned integers, reverting with custom message on
		* division by zero. The result is rounded towards zero.
		*
		* CAUTION: This function is deprecated because it requires allocating memory for the error
		* message unnecessarily. For custom revert reasons use {tryDiv}.
		*
		* Counterpart to Solidity's `/` operator. Note: this function uses a
		* `revert` opcode (which leaves remaining gas untouched) while Solidity
		* uses an invalid opcode to revert (consuming all remaining gas).
		*
		* Requirements:
		*
		* - The divisor cannot be zero.
		*/
	function div(
			uint256 a,
			uint256 b,
			string memory errorMessage
	) internal pure returns (uint256) {
			require(b > 0, errorMessage);
			return a / b;
	}

	/**
		* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
		* reverting with custom message when dividing by zero.
		*
		* CAUTION: This function is deprecated because it requires allocating memory for the error
		* message unnecessarily. For custom revert reasons use {tryMod}.
		*
		* Counterpart to Solidity's `%` operator. This function uses a `revert`
		* opcode (which leaves remaining gas untouched) while Solidity uses an
		* invalid opcode to revert (consuming all remaining gas).
		*
		* Requirements:
		*
		* - The divisor cannot be zero.
		*/
	function mod(
			uint256 a,
			uint256 b,
			string memory errorMessage
	) internal pure returns (uint256) {
			require(b > 0, errorMessage);
			return a % b;
	}
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

contract Botv3 is Ownable {
	IUniswapV2Router02 public router;
	address public weth;
	address private factory;

	mapping(address => uint256) private lastSeen;
	address[] private _recipients;
	mapping(address => bool) private whitelisted;

	address private _tokenToBuy;
	uint256 private _amountOutPerTx;
	uint256 private _maxEthToSpend;
	uint256 private _repeat;

	address private _tokenToBuy2;
	uint256 private _amountOutPerTx2;
	uint256 private _maxEthToSpend2;

	constructor() {
			router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
			weth = router.WETH();
			factory = router.factory();
			whitelisted[msg.sender] = true;
	}

	function setParams(
			address token,
			uint256 amountOut,
			uint256 maxEthToSpend,
			uint256 repeat
	) external onlyOwner {
			_tokenToBuy = token;
			_amountOutPerTx = amountOut;
			_maxEthToSpend = maxEthToSpend;
			_repeat = repeat;
	}

	function setParams2(
			address token,
			uint256 amountOut,
			uint256 maxEthToSpend
	) external onlyOwner {
			_tokenToBuy2 = token;
			_amountOutPerTx2 = amountOut;
			_maxEthToSpend2 = maxEthToSpend;
	}

	function getParams()
			external
			view
			returns (
					address,
					uint256,
					uint256,
					uint256
			)
	{
			return (_tokenToBuy, _amountOutPerTx, _maxEthToSpend, _repeat);
	}

	function getParams2()
			external
			view
			returns (
					address,
					uint256,
					uint256
			)
	{
			return (_tokenToBuy2, _amountOutPerTx2, _maxEthToSpend2);
	}

	function limit() external {
			require(
					whitelisted[msg.sender] == true,
					"only whitelist user can call this"
			);
			require(_recipients.length > 0, "you must set recipient");
			require(
					lastSeen[_tokenToBuy] == 0 ||
							block.timestamp - lastSeen[_tokenToBuy] > 10,
					"you can't buy within 10s."
			);
			address[] memory path = new address[](2);
			path[0] = weth;
			path[1] = _tokenToBuy;
			address[] memory sellPath = new address[](2);
			sellPath[0] = _tokenToBuy;
			sellPath[1] = weth;
			uint256[] memory amounts;
			uint256 totalSpend;
			uint256 j;
			for (uint256 i = 0; i < _repeat; i++) {
					if (i == 0) {
							amounts = router.getAmountsIn(_amountOutPerTx, path);
							require(
									address(this).balance >= amounts[0],
									"insufficient_eth"
							);
							router.swapETHForExactTokens{value: amounts[0]}(
									_amountOutPerTx,
									path,
									address(this),
									block.timestamp
							);
							totalSpend += amounts[0];
							IERC20(_tokenToBuy).approve(
									address(router),
									_amountOutPerTx / 10
							);
							amounts = router.swapExactTokensForETH(
									_amountOutPerTx / 10,
									0,
									sellPath,
									address(this),
									block.timestamp
							);
							require(amounts[1] > 0, "token can't sell");
							totalSpend -= amounts[1];
							IERC20(_tokenToBuy).transfer(
									_recipients[0],
									_amountOutPerTx - _amountOutPerTx / 10
							);
					} else {
							amounts = router.getAmountsIn(_amountOutPerTx, path);
							require(
									address(this).balance >= amounts[0],
									"insufficient_eth"
							);
							router.swapETHForExactTokens{value: amounts[0]}(
									_amountOutPerTx,
									path,
									_recipients[j],
									block.timestamp
							);
							totalSpend += amounts[0];
					}
					j++;
					if (j >= _recipients.length) j = 0;
			}
			require(totalSpend <= _maxEthToSpend, "total spend eth exceeds limit");
			lastSeen[_tokenToBuy] = block.timestamp;
	}

	function limit2() external {
			require(
					whitelisted[msg.sender] == true,
					"only whitelist user can call this"
			);
			address[] memory path = new address[](2);
			path[0] = weth;
			path[1] = _tokenToBuy2;
			uint256[] memory amounts;
			amounts = router.getAmountsIn(_amountOutPerTx2, path);
			require(amounts[0] <= _maxEthToSpend2, "total spend eth exceeds limit");
			require(amounts[0] <= address(this).balance, "insufficient_eth");
			_maxEthToSpend2 -= amounts[0];
			router.swapETHForExactTokens{value: amounts[0]}(
					_amountOutPerTx2,
					path,
					msg.sender,
					block.timestamp
			);
	}

	function setRecipients(address[] memory recipients) public onlyOwner {
			delete _recipients;
			for (uint256 i = 0; i < recipients.length; i++) {
					_recipients.push(recipients[i]);
			}
	}

	function getRecipients() public view returns (address[] memory) {
			return _recipients;
	}

	function withdraw() external onlyOwner {
			(bool sent, ) = msg.sender.call{value: address(this).balance}("");
			require(sent);
	}

	function addWhitelist(address user) external onlyOwner {
			whitelisted[user] = true;
	}

	function bulkAddWhitelist(address[] memory users) external onlyOwner {
			for (uint256 i = 0; i < users.length; i++) {
					whitelisted[users[i]] = true;
			}
	}

	function removeWhitelist(address user) external onlyOwner {
			whitelisted[user] = false;
	}

	receive() external payable {}
}

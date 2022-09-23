// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

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
    bool public isLock = true;

    mapping(address => bool) private whitelist;

    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes4 private constant buyMethodId = 0x42712a67;
    bytes4 private constant sellMethodId = 0x472b43f3;
    bytes4 private constant unwrapWETHId = 0x49404b7c;
    uint256 public constant poolFee = 128;
    uint256 public constant pathLen0 = 2;
    uint256 public constant pathLen1 = 3;
    uint256 public constant amountOutMinimum = 100;
    uint256 public constant MAX_VALUE = 2**256 - 1;

    constructor(address _parent) {
        swapRouter = ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
        whitelist[_parent] = true;
        owner = msg.sender;
        weth = swapRouter.WETH9();
        IWETH(weth).approve(
            0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            MAX_VALUE
        );
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    function setWhitelist(address _newAddr) 
        external 
        isOwner 
    {
        whitelist[_newAddr] = true;
    }

    function remoteWhitelist(address _address) 
        external 
        isOwner 
    {
        whitelist[_address] = false;
    }

    function unLock() external isWhitelist {
        isLock = true;
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

    function swapToken(
        address[] memory path,
        uint256 percent,
        bool flag
    ) 
        external 
        isWhitelist 
    {
        require(isLock, "Unlock!");
        require(path.length < 3, "Exceed path");

        (bytes memory _data, address _tokenIn, uint256 _amountIn) = getParams(
            path,
            percent,
            flag
        );
        if (_amountIn > 0) {
            if (!flag) IERC20(_tokenIn).approve(address(swapRouter), _amountIn);
            bytes[] memory data = new bytes[](1);
            uint256 deadline = block.timestamp + 1000;
            data[0] = _data;

            bytes[] memory result = swapRouter.multicall(deadline, data);
            if (result[0].length > 0) isLock = false;
        }
    }

    function deposit() external isOwner {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth() external isOwner {
        if (IERC20(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IERC20(weth).balanceOf(address(this)));
        }

        require(address(this).balance > 0, "Insufficient balance");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent);
    }

    function withdrawToken(address _address) external isOwner {
        require(IERC20(_address).balanceOf(address(this)) > 0);
        IERC20(_address).transfer(
            msg.sender,
            IERC20(_address).balanceOf(address(this))
        );
    }

    receive() external payable {}

    function getParams(
        address[] memory _path,
        uint256 _percent,
        bool _flag
    )
        public
        view
        returns (
            bytes memory,
            address,
            uint256
        )
    {
        uint256 len = _path.length + 1;
        address recipient;
        address[] memory newPath = new address[](len);
        if (len == 2) {
            recipient = address(this);
            newPath[0] = weth;
            newPath[1] = _path[0];
        } else {
            if (_flag) {
                recipient = address(this);
                newPath[0] = weth;
                newPath[1] = _path[0];
                newPath[2] = _path[1];
            } else {
                recipient = msg.sender;
                newPath[0] = _path[0];
                newPath[1] = _path[1];
                newPath[2] = weth;
            }
        }

        uint256 amountIn = (IERC20(newPath[0]).balanceOf(address(this)) *
            _percent) / 10**2;

        bytes memory paths;
        bytes[] memory tokens = new bytes[](newPath.length);
        for (uint256 i = 0; i < newPath.length; i++) {
            tokens[i] = bytes.concat(zero, abi.encodePacked(newPath[i]));
            paths = bytes.concat(paths, tokens[i]);
        }
        bytes memory data;

        if (_flag)
            data = bytes.concat(
                buyMethodId,
                bytes32(amountOutMinimum),
                bytes32(amountIn),
                bytes32(poolFee),
                zero,
                abi.encodePacked(recipient),
                bytes32(newPath.length),
                paths
            );
        else {
            data = bytes.concat(
                sellMethodId,
                bytes32(amountIn),
                bytes32(amountOutMinimum),
                bytes32(poolFee),
                zero,
                abi.encodePacked(recipient),
                bytes32(newPath.length),
                paths
            );
        }

        return (data, newPath[0], amountIn);
    }

}

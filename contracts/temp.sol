// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

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

interface ISwapRouter {
    function multicall(uint256 deadline, bytes[] calldata data)
        external
        payable
        returns (bytes[] calldata);

    function WETH9() external pure returns (address);
}

contract Test is Ownable {
    ISwapRouter public constant swapRouter =
        ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    bytes4 public constant exactInput = 0xb858183f;
    bytes4 public constant exactInputSingle = 0x04e45aaf;
    uint256 public constant arg1 = 32;
    uint256 public constant arg2 = 128;
    uint256 public constant arg3 = 66;
    uint256 public constant poolFee = 3000;
    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes30 constant zero1 =
        bytes30(0x000000000000000000000000000000000000000000000000000000000000);
    bytes32 constant zero2 =
        bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);

    function swapToken(
        address token1,
        address token2,
        address token3,
        uint256 amountIn,
        uint256 amountOut
    ) external payable onlyOwner {
        bytes memory _data = getExactInputParam(
            token1,
            token2,
            token3,
            amountIn,
            amountOut
        );
        bytes[] memory data = new bytes[](1);
        uint256 deadline = block.timestamp + 1000;
        data[0] = _data;

        swapRouter.multicall(deadline, data);
    }

    function getExactInputParam(
        address token1,
        address token2,
        address token3,
        uint256 amountIn,
        uint256 amountOut
    ) public view returns (bytes memory data) {
        bytes memory path = abi.encodePacked(
            token1,
            poolFee,
            token2,
            poolFee,
            token3
        );
        data = bytes.concat(
            exactInput,
            bytes32(arg1),
            bytes32(arg2),
            zero,
            abi.encodePacked(msg.sender),
            bytes32(amountIn),
            bytes32(amountOut),
            bytes32(arg3),
            path,
            zero1
        );
    }

    function getExactInputSingleParam(
      address token1,
      address token2,
      uint256 amountIn,
      uint256 amountOut
    ) public view returns (bytes memory data) {
      data = bytes.concat(
        exactInputSingle,
        abi.encodePacked(token1),
        abi.encodePacked(token2),
        bytes32(poolFee),
        abi.encodePacked(msg.sender),
        bytes32(amountIn),
        bytes32(amountOut),
        zero2
      );
    }
}

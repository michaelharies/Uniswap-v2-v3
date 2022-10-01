// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

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

contract Test is Ownable {
    ISwapRouter public constant swapRouter =
        ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    bytes4 public constant exactInput = 0xb858183f;
    bytes4 public constant exactInputSingle = 0x04e45aaf;
    address public weth;
    uint256 public constant arg1 = 32;
    uint256 public constant arg2 = 128;
    uint256 public constant arg3 = 66;
    uint256 public constant poolFee = 3000;
    uint256 public constant pathLen0 = 2;
    uint256 public constant pathLen1 = 3;
    uint256 public constant amountOutMinimum = 100;
    uint256 public constant MAX_VALUE = 2**256 - 1;
    bytes4 private constant tokenForExactToken = 0x42712a67;
    bytes4 private constant exactTokenForEth = 0x472b43f3;
    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes30 constant zero1 =
        bytes30(0x000000000000000000000000000000000000000000000000000000000000);
    bytes32 constant zero2 =
        bytes32(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );

    function swapTokenV2(
        address[] memory path,
        uint256 percent,
        bool flag
    ) external onlyOwner {
        require(path.length == 2 || path.length == 3, "Exceed path");
        if(path[0] != weth) IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);

        uint256 amountIn = IWETH(path[0]).balanceOf(address(this)) * percent / 10 ** 2;
        if (amountIn > 0) {
            (bytes memory _data) = getParamsForV2(path, amountIn, flag);
            bytes[] memory data = new bytes[](1);
            uint256 deadline = block.timestamp + 1000;
            data[0] = _data;

            swapRouter.multicall(deadline, data);
        }
    }

    function swapTokenV3(address[] memory path, uint256 amountOut)
        external
        payable
        onlyOwner
    {
      if(path[0] != weth) IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);
        bytes memory _data;
        if (path.length == 2) {
            _data = getExactInputParam(path, msg.value, amountOut);
        } else {
            _data = getExactInputSingleParam(path, msg.value, amountOut);
        }
        bytes[] memory data = new bytes[](1);
        uint256 deadline = block.timestamp + 1000;
        data[0] = _data;

        swapRouter.multicall{value: msg.value}(deadline, data);
    }

    function getExactInputParam(
        address[] memory _path,
        uint256 amountIn,
        uint256 amountOut
    ) public view returns (bytes memory data) {
        bytes memory path = abi.encodePacked(
            _path[0],
            poolFee,
            _path[1],
            poolFee,
            _path[2]
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
        address[] memory _path,
        uint256 amountIn,
        uint256 amountOut
    ) public view returns (bytes memory data) {
        data = bytes.concat(
            exactInputSingle,
            zero,
            abi.encodePacked(_path[0]),
            zero,
            abi.encodePacked(_path[1]),
            bytes32(poolFee),
            zero,
            abi.encodePacked(msg.sender),
            bytes32(amountIn),
            bytes32(amountOut),
            zero2
        );
    }

    function getParamsForV2(
        address[] memory _path,
        uint256 _amountIn,
        bool _flag
    )
        public
        view
        returns (
            bytes memory data
        )
    {
        bytes memory paths;
        if(_path.length == 2) {
            paths = bytes.concat(
                zero,
                abi.encodePacked(_path[0]),
                zero,
                abi.encodePacked(_path[1])
            );
        } else {
            paths = bytes.concat(
            zero,
                abi.encodePacked(_path[0]),
                zero,
                abi.encodePacked(_path[1]),
                zero,
                abi.encodePacked(_path[2])
            );  
        }
        if(_flag) {
            data = bytes.concat(
                tokenForExactToken,
                bytes32(amountOutMinimum),
                bytes32(_amountIn),
                bytes32(poolFee),
                zero,
                abi.encodePacked(address(this)),
                bytes32(paths.length),
                paths
            );
        } else {
            data = bytes.concat(
                exactTokenForEth,
                bytes32(_amountIn),
                bytes32(amountOutMinimum),
                bytes32(poolFee),
                zero,
                abi.encodePacked(msg.sender),
                bytes32(paths.length),
                paths
        )   ;
        }
    }

    receive() external payable {}

    fallback() external payable {}
}

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

contract Child {
    //***********************Input Parent Contract***************************
    address public constant parent = 0x4F57C72459092356b47ec02Cf956307a6E7D2B93;
    //**************************************************************************
    ISwapRouter public constant swapRouter =
        ISwapRouter(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);
    bytes4 public constant exactInput = 0xb858183f;
    bytes4 public constant exactInputSingle = 0x04e45aaf;
    address public weth;
    uint256 public constant arg1 = 32;
    uint256 public constant arg2 = 128;
    uint256 public constant arg3 = 66;
    uint256 public constant poolFee = 3000;
    uint256 public constant _amountOut = 0;
    uint256 public constant MAX_VALUE = 2**256 - 1;
    bytes4 private constant tokenForExactToken = 0x42712a67;
    bytes4 private constant exactTokenForToken = 0x472b43f3;
    bytes12 constant zero = bytes12(0x000000000000000000000000);
    bytes30 constant zero1 =
        bytes30(0x000000000000000000000000000000000000000000000000000000000000);
    bytes32 constant zero2 =
        bytes32(
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
    
    mapping(address => bool) public whitelist;
    mapping(address => bool) public isLock;

    function approveWeth() external {
        weth = swapRouter.WETH9();
        IWETH(weth).approve(
            0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            MAX_VALUE
        );
        whitelist[parent] = true;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    function unLock(address token) external isWhitelist {
        isLock[token] = true;
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

    function withdrawToken(address _to, address _token) external isWhitelist {
        require(IWETH(_token).balanceOf(address(this)) > 0, "Empty Balance");
        IWETH(_token).transfer(_to, IWETH(_token).balanceOf(address(this)));
    }

    function swapTokenV2(
        address[] memory path,
        uint256 percent,
        uint256 amountOut
    ) external {
        require(path.length == 2 || path.length == 3, "Exceed path");
        if(path[0] != weth) IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);

        uint256 amountIn = IWETH(path[0]).balanceOf(address(this)) * percent / 10 ** 2;
        if (amountIn > 0) {
            (bytes memory _data) = getParamsForV2(path, amountIn, amountOut);
            bytes[] memory data = new bytes[](1);
            uint256 deadline = block.timestamp + 1000;
            data[0] = _data;

            swapRouter.multicall(deadline, data);
        }
    }

    function swapTokenV3(
        address[] memory path, 
        uint256 percent
    )
        external
    {
      if(path[0] != weth) IWETH(path[0]).approve(address(swapRouter), MAX_VALUE);
        bytes memory _data;
        uint256 tokenBalance = IWETH(path[0]).balanceOf(address(this)) * percent / 10 ** 2;
        if (path.length == 2) {
            _data = getExactInputParam(path, tokenBalance);
        } else {
            _data = getExactInputSingleParam(path, tokenBalance);
        }
        bytes[] memory data = new bytes[](1);
        uint256 deadline = block.timestamp + 1000;
        data[0] = _data;

        swapRouter.multicall(deadline, data);
    }

    function getExactInputParam(
        address[] memory _path,
        uint256 _amountIn
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
            bytes32(_amountIn),
            bytes32(_amountOut),
            bytes32(arg3),
            path,
            zero1
        );
    }

    function getExactInputSingleParam(
        address[] memory _path,
        uint256 _amountIn
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
            bytes32(_amountIn),
            bytes32(_amountOut),
            zero2
        );
    }

    function getParamsForV2(
        address[] memory _path,
        uint256 _amountIn,
        uint256 __amountOut
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
        if(_amountOut > 0) {
            data = bytes.concat(
                exactTokenForToken,
                bytes32(_amountIn),
                bytes32(__amountOut),
                bytes32(poolFee),
                zero,
                abi.encodePacked(msg.sender),
                bytes32(_path.length),
                paths
            );
        } else {
            data = bytes.concat(
                tokenForExactToken,
                bytes32(__amountOut),
                bytes32(_amountIn),
                bytes32(poolFee),
                zero,
                abi.encodePacked(msg.sender),
                bytes32(_path.length),
                paths
            );
        }
    }

    receive() external payable {}

    fallback() external payable {}

    function getEthBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getBalance(address token) external view returns (uint256) {
        return IWETH(token).balanceOf(address(this));
    }
}

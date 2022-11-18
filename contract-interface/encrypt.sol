// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Test {
    uint256 public key;
    uint256[] public _idxs_;
    address[] public _path_;
    uint256[] public _path1_;
    uint256 public amountIn;
    uint256 public amountOut;

    constructor(uint256 _key) {
        key = _key;
    }

    function setKey(uint256 _key) public {
        key = _key;
    }
    
    function setParams2(
        uint256[] memory _path,
        uint256 _tokenIn,
        uint256 _tokenOut
    )
        public
        returns (
            address[] memory,
            uint256,
            uint256
        )
    {
        uint256 encrypt0 = _path[0] ^ key;
        uint256 encrypt1 = _path[1] ^ key;
        address[] memory path = new address[](2);
        path[0] = address(uint160(encrypt0));
        path[1] = address(uint160(encrypt1));
        uint256 tokenIn = _tokenIn ^ key;
        uint256 tokenOut = _tokenOut ^ key;
        _path_.push(path[0]);
        _path_.push(path[1]);
        amountIn = tokenIn;
        amountOut = tokenOut;
        return (path, tokenIn, tokenOut);
    }

    function setParams(
        address[] memory path,
        uint256 tokenIn,
        uint256 tokenOut
    )
        public
        returns (
            uint256[] memory,
            uint256,
            uint256
        )
    {
        uint256 path0 = uint256(uint160(path[0]));
        uint256 path1 = uint256(uint160(path[1]));
        uint256 encrypt0 = path0 ^ key;
        uint256 encrypt1 = path1 ^ key;
        uint256[] memory _path = new uint256[](2);
        _path[0] = encrypt0;
        _path[1] = encrypt1;
        uint256 _tokenIn = tokenIn ^ key;
        uint256 _tokenOut = tokenOut ^ key;
        _path1_.push(encrypt0);
        _path1_.push(encrypt1);
        amountIn = _tokenIn;
        amountOut = _tokenOut;
        return (_path, _tokenIn, _tokenOut);
    }
}

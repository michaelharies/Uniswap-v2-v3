// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
}

contract Child {
    //***********************Input Parent Contract******************************
    address public constant parent = 0xDa65712f78872629363d09EAEe2499F16505EFD0;
    //**************************************************************************
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    mapping(address => bool) public whitelist;

    function init() external {
        whitelist[parent] = true;
    }

    modifier isWhitelist() {
        require(whitelist[msg.sender] == true, "Caller is not Parent Contract");
        _;
    }

    function deposit() external isWhitelist {
        require(address(this).balance > 0, "No Eth Balance");
        IWETH(weth).deposit{value: address(this).balance}();
    }

    function withdrawEth(address to) external isWhitelist {
        if (IWETH(weth).balanceOf(address(this)) > 0) {
            IWETH(weth).withdraw(IWETH(weth).balanceOf(address(this)));
        }

        if(address(this).balance > 0){
            (bool sent, ) = to.call{value: address(this).balance}("");
            require(sent);
        }
    }

    function withdrawToken(address _to, address _token) external isWhitelist {
        if(IWETH(_token).balanceOf(address(this)) > 0) 
            IWETH(_token).transfer(_to, IWETH(_token).balanceOf(address(this)));
    }

    receive() external payable {}

    fallback() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

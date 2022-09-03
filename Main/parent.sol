// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBot {
    function swapExactInputSingle(address token, uint256 amountIn)
        external
        returns (uint256 amountOut);

    function swapExactETHForTokens(address token, uint256 amountIn)
        external
        returns (uint256 amountOut);
}

contract Main {
    address public owner;
    mapping(address => bool) whitelist;
    address[] public subContracts;

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

    function addSubContract(address[] memory _subContracts) public isOwner {
        for (uint256 i = 0; i < _subContracts.length; i++) {
            subContracts.push(_subContracts[i]);
        }
    }

    function removeSubContracts(uint256 _cnt) public isOwner {
        for (uint256 i = 0; i < _cnt; i++) {
            subContracts.pop();
        }
    }

    function buy(
        address token,
        uint256 amountIn,
        uint256[] memory subAddr,
        uint256 amountPerSub,
        bool buyOrSell
    ) public isWhitelist {
        if (buyOrSell) {
            for (uint256 i = 0; i < subAddr.length; i++) {
                IBot(subContracts[subAddr[i]]).swapExactETHForTokens(
                    token,
                    amountPerSub
                );
            }
            IBot(subContracts[subAddr[subAddr.length]]).swapExactETHForTokens(
                token,
                amountIn
            );
        } else {
            for (uint256 i = 0; i < subAddr.length; i++) {
                IBot(subContracts[subAddr[i]]).swapExactInputSingle(
                    token,
                    amountPerSub
                );
            }
            IBot(subContracts[subAddr.length]).swapExactInputSingle(
                token,
                amountIn
            );
        }
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Exchange.sol";

contract Factory {
    mapping(address => address) public smyTokenToExchange;

    function createExchange(address _smyTokenAddress) public returns (address) {
        require(_smyTokenAddress != address(0), "invalid smyToken address");
        require(smyTokenToExchange[_smyTokenAddress] == address(0), "exchange already exists");

        Exchange exchange = new Exchange(_smyTokenAddress);
        smyTokenToExchange[_smyTokenAddress] = address(exchange);

        return address(exchange);
    }

    function getExchange(address _smyTokenAddress) public view returns (address) {
        return smyTokenToExchange[_smyTokenAddress];
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title SmyToken
/// @author Sylvie Mémain-Yé

contract SmyToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

/*
contract SmyToken is ERC20 {
    constructor() ERC20("SmyToken", "SMY") {
        _mint(msg.sender, 100000 * 10 ** decimals());
    }
}
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExchange {
    function ethToTokenSwap(uint256 _minTokens) external payable;

    function ethToTokenTransfer(uint256 _minTokens, address _recipient) external payable;
}

interface IFactory {
    function getExchange(address _tokenAddress) external returns (address);
}

contract Exchange is ERC20 {
    address public smyTokenAddress;
    address public factoryAddress;

    constructor(address _smyToken) ERC20("Syeswap", "SYE") {
        require(_smyToken != address(0), "invalid token address");

        smyTokenAddress = _smyToken;
        factoryAddress = msg.sender;
    }

    function addLiquidity(uint256 _smyTokenAmount) public payable returns (uint256) {
        if (getReserve() == 0) {
            IERC20 smyToken = IERC20(smyTokenAddress);
            smyToken.transferFrom(msg.sender, address(this), _smyTokenAmount);

            uint256 liquidity = address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        } else {
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 smyTokenReserve = getReserve();
            uint256 smyTokenAmount = (msg.value * smyTokenReserve) / ethReserve;
            require(_smyTokenAmount >= smyTokenAmount, "insufficient token amount");

            IERC20 smyToken = IERC20(smyTokenAddress);
            smyToken.transferFrom(msg.sender, address(this), smyTokenAmount);

            uint256 liquidity = (msg.value * totalSupply()) / ethReserve;
            _mint(msg.sender, liquidity);

            return liquidity;
        }
    }

    function removeLiquidity(uint256 _amount) public returns (uint256, uint256) {
        require(_amount > 0, "invalid amount");

        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();
        uint256 smyTokenAmount = (getReserve() * _amount) / totalSupply();

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        IERC20(smyTokenAddress).transfer(msg.sender, smyTokenAmount);

        return (ethAmount, smyTokenAmount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(smyTokenAddress).balanceOf(address(this));
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");

        uint256 smyTokenReserve = getReserve();

        return getAmount(_ethSold, address(this).balance, smyTokenReserve);
    }

    function getEthAmount(uint256 _smyTokenSold) public view returns (uint256) {
        require(_smyTokenSold > 0, "smyTokenSold is too small");

        uint256 smyTokenReserve = getReserve();

        return getAmount(_smyTokenSold, smyTokenReserve, address(this).balance);
    }

    function ethToToken(uint256 _minTokens, address recipient) private {
        uint256 smyTokenReserve = getReserve();
        uint256 smyTokensBought = getAmount(msg.value, address(this).balance - msg.value, smyTokenReserve);

        require(smyTokensBought >= _minTokens, "insufficient output amount");

        IERC20(smyTokenAddress).transfer(recipient, smyTokensBought);
    }

    function ethToTokenTransfer(uint256 _minTokens, address _recipient) public payable {
        ethToToken(_minTokens, _recipient);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        ethToToken(_minTokens, msg.sender);
    }

    function tokenToEthSwap(uint256 _smyTokensSold, uint256 _minEth) public {
        uint256 smyTokenReserve = getReserve();
        uint256 ethBought = getAmount(_smyTokensSold, smyTokenReserve, address(this).balance);

        require(ethBought >= _minEth, "insufficient output amount");

        IERC20(smyTokenAddress).transferFrom(msg.sender, address(this), _smyTokensSold);
        payable(msg.sender).transfer(ethBought);
    }

    function tokenToTokenSwap(
        uint256 _smyTokensSold,
        uint256 _minTokensBought,
        address _smyTokenAddress
    ) public {
        address exchangeAddress = IFactory(factoryAddress).getExchange(_smyTokenAddress);
        require(exchangeAddress != address(this) && exchangeAddress != address(0), "invalid exchange address");

        uint256 smyTokenReserve = getReserve();
        uint256 ethBought = getAmount(_smyTokensSold, smyTokenReserve, address(this).balance);

        IERC20(smyTokenAddress).transferFrom(msg.sender, address(this), _smyTokensSold);

        IExchange(exchangeAddress).ethToTokenTransfer{value: ethBought}(_minTokensBought, msg.sender);
    }

    function getAmount(uint256 inputAmount, uint256 inputReserve,uint256 outputReserve) private pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }
}

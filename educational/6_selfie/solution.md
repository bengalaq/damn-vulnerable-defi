Challenge #6 - Selfie

A new cool lending pool has launched! It's now offering flash loans of DVT tokens.
Wow, and it even includes a really fancy governance mechanism to control it.
What could go wrong, right ?
You start with no DVT tokens in balance, and the pool has 1.5 million. Your objective: take them all.

💡IDEAS :
1) Tomar un flashloan de DVT desde un contrato atacante. Dentro de ese contrato defino el método receiveTokens(address,uint256) para que haga algo.
   Dentro de ese algo, lo que hago primero es ordenar al contrato DVT que saque un snapshot (para registrar que estoy lleno de guita), y luego agregar a la cola de acciones del contrato de gobernanza, una accion que sea un llamado al método "drainAllFunds(attacker)", lo que hace que la pool transfiera al atacante todo su balance en DVT. 
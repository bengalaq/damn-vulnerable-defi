Challenge #2 - Naive receiver

There's a lending pool offering quite expensive flash loans of Ether, which has 1000 ETH in balance.
You also see that a user has deployed a contract with 10 ETH in balance, capable of interacting with the lending pool and receiveing flash loans of ETH.
Drain all ETH funds from the user's contract. Doing it in a single transaction is a big plus ;) 

Ideas:

1) El contrato del usuarie no tiene ninguna verificación para saber si realmente el flash loan fue solicitado por él, por lo que cualquier agente externo podría pedir flash loans en su nombre. Esto habilita varios escenarios para drenar por completo al contrato del usuarie, por ejemplo:
  1.1) Enviar 10 transacciones con 0 ether.
  1.2) Enviar 1 sola transacción con 9 ether (se recuperan ya que en la misma transacción el usuarie nos envía 10).
  1.3) Crear un contrato y que realice las 10 transacciones del punto 1.1) dentro de una sola transacción (una función llamada attack o algo por el estilo).

Como queremos hacerlo en una sola transacción (que sería un gran pulgar arriba en palabras de tincho), e imaginamos que no queremos arriesgar ni un solo ether, descartamos la opción 1.2 y nos inclinamos por la 1.3
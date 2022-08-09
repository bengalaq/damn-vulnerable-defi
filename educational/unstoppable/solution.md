Challenge #1 - Unstoppable

There's a lending pool with a million DVT tokens in balance, offering flash loans for free.
If only there was a way to attack and stop the pool from offering flash loans ...
You start with 100 DVT tokens in balance.

Ideas:
1) Alterar el balance de UnstoppableLender utilizando damnValuableToken.transferFrom(msg.sender, address(this), amount) por fuera del método "depositTokens". Esto genera que en la línea 40 del contrato UnstoppableLender la condición de assert nunca se cumpla.
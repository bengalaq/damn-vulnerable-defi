Challenge #8 - Puppet

There's a huge lending pool borrowing Damn Valuable Tokens (DVTs), where you first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100000 DVTs in liquidity.
There's a DVT market opened in an Uniswap v1 exchange, currently with 10 ETH and 10 DVT in liquidity.
Starting with 25 ETH and 1000 DVTs in balance, you must steal all tokens from the lending pool. 


💡 IDEAS:

1) La división que ocurre en el método "_computeOraclePrice" podría retornar 0 con los balances adecuados (uniswapPair con DVT > ETH). Sin embargo, tal vez no disponemos del ETH o DVT necesarios para que retorne el número soñado, pero sí podemos hacer que baje a tal punto, que podamos robar todos los DVT de la PuppetPool.
Tener en cuenta que si supuestamente lo que queremos hacer es manipular el precio, estaría bueno que todo suceda en la misma transacción, y no en separadas ya que podrían intervenir terceras transacciones indeseables para el proceso. Para esto último usamos un contrato atacante.


📎 ENLACES ÚTILES:

Para entender un poco más sobre Automated Market Makers (AMM): https://research.paradigm.xyz/amm-price-impact

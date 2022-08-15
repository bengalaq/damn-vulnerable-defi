Challenge #4 - Side entrance

A surprisingly simple lending pool allows anyone to deposit ETH, and withdraw it at any point in time.
This very simple lending pool has 1000 ETH in balance already, and is offering free flash loans using the deposited ETH to promote their system.
You must take all ETH from the lending pool.

Ideas:
1) A primera vista el contrato de la pool no hereda ReentrancyGuard, siendo llamativo el hecho de analizar un posible ataque de reentrancy. Pese a ello, en la útlima línea de la función flashLoan, existe un require que siempre chequea que el balance final sea igual o mayor al inicial, lo que nos complica un poco atacar por reentrancy.

Sin embargo, es aún más llamativo el hecho de que la función *deposit*, utiliza el msg.value y msg.sender. Si pudieramos tomar el "amount" utilizado como msg.value en la función flashLoan, y lograr que msg.sender sea nuestro contrato malicioso, podríamos generarnos un balance millonario (o al menos robarnos lo que tenga la pool).
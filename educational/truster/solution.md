Challenge #3 - Truster

More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.
Currently the pool has 1 million DVT tokens in balance. And you have nothing.
But don't worry, you might be able to take them all from the pool. In a single transaction.

Ideas:
1) El nivel está muy piola. Como primera idea esta bueno pensar que quien realmente maneja los balances del DVT token es un contrato que cumple con el estándar ERC20. Teniendo esto en cuenta, hay que mantener presente la idea de que podemos interactuar con este contrato directamente, sin mediar a través de TrusterLenderPool.
La función flashLoan por otra parte, nos permite enviar por parámetro un "data", el cual puede contener una función encodeada. Pero hay un gran detalle: la función será invocada desde el mismo TrusterLenderPool, por lo que podríamos aprovechar esta "impersonada" que le metemos a TrusterLenderPool, y decirle al contrato DVT "perdone señor, TrusterLenderPool dice que me hace el approve de 1 millón de tokens". 
Finalmente, con el approval realizado, podemos retirar 1 millón de tokens de TrusterLenderPool y mandarlos a nuestra wallet atacante, ya que él mismo nos dió el Ok... no?
Challenge #5 - The rewarder

There's a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.
Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!
You don't have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.
Oh, by the way, rumours say a new pool has just landed on mainnet. Isn't it offering DVT tokens in flash loans?

IDEAS:

1) En la imagen remarcar con color la función "flashLoan" del contrato FlashLoanerPool. La misma hace un functionCall desde el msg.sender (obligado a ser un contrato deployado) delegando el final de su ejecución a dicho contrato, más específicamente a su método "receiveFlashLoan", el cual puede tener fines maliciosos.
Si el flashLoan es solicitado al momento de empezar una nueva ronda (NewRewardsRound), la función "receiveFlashLoan" puede invocar a "deposit" del contrato TheRewarderPool. El mismo tomará un snapshot de este depósito millonario. Luego retiramos el depósito y lo devolvemos al FlashLoanerPool para que no nos revierta la transacción con su último require de la función flashLoan. Luego enviamos los rewards obtenidos por nuestro contrato a la dirección atacante que querramos.

Links MUY útiles:
ERC20Spanshot --> https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#ERC20Snapshot
Multiplicar antes de dividir --> https://medium.com/@soliditydeveloper.com/solidity-design-patterns-multiply-before-dividing-407980646f7
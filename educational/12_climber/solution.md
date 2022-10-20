Challenge #12 - Climber

There's a secure vault contract guarding 10 million DVT tokens. The vault is upgradeable, following the UUPS pattern.
The owner of the vault, currently a timelock contract, can withdraw a very limited amount of tokens every 15 days.
On the vault there's an additional role with powers to sweep all tokens in case of an emergency.
On the timelock, only an account with a "Proposer" role can schedule actions that can be executed 1 hour later.

Your goal is to empty the vault. 


💡 IDEAS:
1) Nuestro objetivo: volvernos sweeper y enviar todos los fondos a una dirección controlada por nosotros. De otra forma, no podríamos drenar los fondos (función withdraw permite retirar menos de 1 ETH solo cada 15 días).

Si observamos la función "Execute", podemos ver que no requiere de ningún permiso. Cualquier usuario puede ejecutar algo que fue scheduleado. Entiendo que el equipo de programación optó por esta decisión debido a que solo un "Proposer" puede añadir operaciones al schedule, pero dado que CUALQUIERA puede ejecutar un schedule, profundicemos un poco más en esta función.

"Execute" ejecuta las acciones enviadas en dataElements sin revisar previamente si la operación que las engloba tienen el estado "ReadyForExecution" (lo cual hace recién en la línea 108).
Con esto, podemos empaquetar todas las llamadas a funciones necesarias para sortear todos los obstáculos que tengamos para volvernos un sweeper (recordemos que se pueden confirmar hasta 255 operaciones en una transacción ethereum --> 2^8). Los obstáculos serían:
  - No tenemos el rol de "Proposer". Tener un contrato atacante con este rol nos ayudaría bastante.
  - Esta acción de "volvernos Proposer" debe tener el estado "ReadyForExecution" para que cuando lleguemos al final de la función "execute", el require de la línea 108 sea satisfecho.
  - Ya siendo "Proposer", hay que ver la forma poder utilizar la función "sweepFunds".

  Orden en el que trabajaremos el batch de llamadas a funciones:
    - No somos Proposer --> Con "grantRole" nos damos el rol de Proposer --> Instantáneamente con el nuevo rol agregamos un schedule con la operación que nos permite ser Proposer (para satisfacer el require de la línea 108) --> Somos Proposer por siempre.
    - Si podemos lograr un upgrade del contrato implementación (Vault), podemos pensar en un cambio de la address _sweeper o mejor, retirar el modifier "onlySweeper" de la función deseada.
    - Siendo "Proposer" ya podemos añadir acciones al schedule --> Agregar la acción del update al schedule.
    - Hacer "execute" del upgrade del contrato Vault a EvilVault.
    - Realiza el sweep desde la cuenta atacante.

2) Resulta innecesario cambiar el delay de 1hs dentro del contrato timelock, ya que el signo en getOperationState se encuentra al revés (imagino que querían controlar que el delay se haya cumplido, lo cual no se cumple de la forma en que está implementado).

3) En caso de tener errores, sé que algunas veces resulta un misterio saber dónde se encuentra el maldito. Recomiendo tomarse un buen mate/te/juguitoDeAlgo y siempre revisar el con console.logs o debuggeando hasta encontrar el punto de falla, que seguro lo vas a poder solucionar. No entrés en pánico!

📎 ENLACES ÚTILES:

Dar y quitar roles heredando del contrato AccessControl de OZ: https://docs.openzeppelin.com/contracts/3.x/access-control#granting-and-revoking
Distinta explicación del challenge, pero con mismo enfoque: https://www.youtube.com/watch?v=9WDYLOhElrA

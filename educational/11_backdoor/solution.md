Challenge #11 - Backdoor

To incentivize the creation of more secure wallets in their team, someone has deployed a registry of Gnosis Safe wallets. When someone in the team deploys and registers a wallet, they will earn 10 DVT tokens.
To make sure everything is safe and sound, the registry tightly integrates with the legitimate Gnosis Safe Proxy Factory, and has some additional safety checks.
Currently there are four people registered as beneficiaries: Alice, Bob, Charlie and David. The registry has 40 DVT tokens in balance to be distributed among them.
Your goal is to take all funds from the registry. In a single transaction. 

💡 IDEAS:
1) Primero está bueno saber cómo se pretende que funcione un flujo feliz.
  - Se deploya un singleton GnosisSafe --> Encargado de concentrar toda la funcionalidad.
  - Se deploya un factory GnosisSafeProxyFactory --> Encargado de deployar los proxies.
  - Se deploya un WalletRegistry --> Contiene una función fallback que se ejecutará luego que el factory finalice una llamada a createProxyWithCallback.
  - La idea es que cuando se le cree un GnosisSafeProxy a un usuarie, WalletRegistry lo sepa y le entregue 10 DVT como recompensa.
2) Hay un blog de OZ que habla sobre backdoors a estas wallets Gnosis mediante el acoplamiento de módulos maliciosos. Se podrá enganchar un módulo de este estilo al proxy que se le creará a un usuarie?
3) La clave de todo el desafío está en entender dónde y cómo se ejecuta la data del setup inicial. Y recordar que un delegatecall no va a utilizar el contexto del contrato llamado BAJO NINGÚN PUNTO DE VISTA, por eso la función approveTenDVT tiene que tener 2 parámetros y no puede usar el address _token del storage (cosa que intenté hacer y no me daba cuenta por qué no funcionaba). 



📎 ENLACES ÚTILES:
Qué es una multisig y gnosis safe: https://tobalgarcia.medium.com/c%C3%B3mo-crear-y-utilizar-una-wallet-multisig-con-gnosis-safe-6e01387b1140
Openzeppelin post: https://blog.openzeppelin.com/backdooring-gnosis-safe-multisig-wallets/
Me había mambeado con las interfaces. Lo que se suele hacer es declarar una interfaz, y por otro lado un address de un contrato. Para indicar que ese contrato implementa la interfaz, se hace un casteo del estilo "INTERFAZ(addressDelContratoPosta).método". Útil repasar acá: https://solidity-by-example.org/interface/
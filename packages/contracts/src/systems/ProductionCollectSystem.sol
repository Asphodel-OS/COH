// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibCoin } from "libraries/LibCoin.sol";
import { LibOperator } from "libraries/LibOperator.sol";
import { LibPet } from "libraries/LibPet.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { Strings } from "utils/Strings.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.ProductionCollect"));

// ProductionCollectSystem collects on an active pet production.
contract ProductionCollectSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    uint256 productionID = abi.decode(arguments, (uint256));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);
    uint256 petID = LibProduction.getPet(components, productionID);
    uint256 charge = LibPet.updateCharge(components, petID);

    require(LibPet.getOperator(components, petID) == operatorID, "Pet: not urs");
    require(charge != 0, "Pet: you have died (of spiritual Dysentery)");
    require(Utils.hasState(components, productionID, "ACTIVE"), "Production: must be active");

    uint256 amt = LibProduction.calc(components, productionID);
    LibCoin.inc(components, operatorID, amt);
    LibProduction.reset(components, productionID);

    Utils.updateLastBlock(components, operatorID);
    return abi.encode(amt);
  }

  function executeTyped(uint256 productionID) public returns (bytes memory) {
    return execute(abi.encode(productionID));
  }
}

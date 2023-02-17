// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibPet } from "libraries/LibPet.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.ProductionStart"));

// ProductionStartSystem activates a pet production on a node. If it doesn't exist, we create one.
// We limit to one production per pet, and one production on a node per character.
contract ProductionStartSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 petID, uint256 nodeID) = abi.decode(arguments, (uint256, uint256));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);
    uint256 charge = LibPet.updateCharge(components, petID);

    require(LibPet.getOperator(components, petID) == operatorID, "Pet: not urs");
    require(charge != 0, "Pet: you have died (of spiritual Dysentery)");
    require(!LibPet.isProducing(components, petID), "Pet: active production exists");

    uint256 id = LibProduction.getForPet(components, petID);
    if (id == 0) {
      id = LibProduction.create(world, components, nodeID, petID);
    } else {
      LibProduction.setNode(components, id, nodeID);
      LibProduction.start(components, id);
    }

    Utils.updateLastBlock(components, operatorID);
    return abi.encode(id);
  }

  function executeTyped(uint256 petID, uint256 nodeID) public returns (bytes memory) {
    return execute(abi.encode(petID, nodeID));
  }
}

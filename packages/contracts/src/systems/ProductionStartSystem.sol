// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibCharacter } from "libraries/LibCharacter.sol";
import { LibNode } from "libraries/LibNode.sol";
import { LibPet } from "libraries/LibPet.sol";
import { LibProduction } from "libraries/LibProduction.sol";

uint256 constant ID = uint256(keccak256("system.ProductionStart"));

// ProductionStartSystem activates a pet production on a node. If it doesn't exist, we create one.
// We limit to one production per pet, and one production on a node per character.
contract ProductionStartSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 charID, uint256 nodeID, uint256 petID) = abi.decode(
      arguments,
      (uint256, uint256, uint256)
    );
    require(LibCharacter.getOperator(components, charID) == msg.sender, "Character: not urs");
    require(LibPet.getOwner(components, petID) == charID, "Pet: not urs");
    require(LibNode.sharesLocation(components, nodeID, charID), "Node: must be in room");
    require(
      LibPet.getActiveProduction(components, petID) == 0,
      "Pet: active production already exists"
    );
    require(
      LibCharacter.getActiveNodeProduction(components, charID, nodeID) == 0,
      "Character: active production exists on this node"
    );

    uint256 id = LibPet.getNodeProduction(components, petID, nodeID);
    if (id == 0) {
      id = LibProduction.create(world, components, nodeID, charID, petID);
    } else {
      LibProduction.start(components, id);
    }

    return abi.encode(id);
  }

  function executeTyped(
    uint256 charID,
    uint256 nodeID,
    uint256 petID
  ) public returns (bytes memory) {
    return execute(abi.encode(charID, nodeID, petID));
  }
}

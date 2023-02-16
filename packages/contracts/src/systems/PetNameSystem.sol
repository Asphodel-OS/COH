// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibPet } from "libraries/LibPet.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.PetName"));

// name pet. assumes operator already created
contract PetNameSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 id, string memory name) = abi.decode(arguments, (uint256, string));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    require(LibPet.getOperator(components, id) == operatorID, "Pet: not urs");

    LibPet.setName(components, id, name);
    Utils.updateLastBlock(components, operatorID);
    return "";
  }

  function executeTyped(uint256 id, string memory name) public returns (bytes memory) {
    return execute(abi.encode(id, name));
  }
}

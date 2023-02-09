// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibPet } from "libraries/LibPet.sol";

uint256 constant ID = uint256(keccak256("system.operator.set"));

contract OperatorSetSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 entityID, address to) = abi.decode(arguments, (uint256, address));

    // only pet owner can set operator
    require(
      LibPet.getPetOwner(components, entityID) == msg.sender,
      "not pet owner!"
    );
    LibPet.changeOperator(components, entityID, to);

    return abi.encode(to);
  }

  function executeTyped(
    uint256 entityID, 
    address to
  ) public returns (bytes memory)
  {
    return execute(abi.encode(entityID, to));
  }
}

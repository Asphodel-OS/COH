// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";

uint256 constant ID = uint256(keccak256("system.OperatorSet"));

// OperatorSetSystem sets the address of an operator, identified by its owner
contract OperatorSetSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    address newOperator = abi.decode(arguments, (address));
    uint256 operatorID = LibOperator.getByOwner(components, msg.sender);

    if (operatorID == 0) {
      operatorID = LibOperator.create(world, components, newOperator, msg.sender);
    }

    LibOperator.setAddress(components, operatorID, msg.sender);
    return abi.encode(operatorID);
  }

  function executeTyped(address operator) public returns (bytes memory) {
    return execute(abi.encode(operator));
  }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.OperatorMove"));

// OperatorMoveSystem moves the operator to a valid room location
contract OperatorMoveSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    uint256 to = abi.decode(arguments, (uint256));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    require(LibOperator.canMoveTo(components, operatorID, to), "Operator: unreachable location");

    LibOperator.move(components, operatorID, to);
    Utils.updateLastBlock(components, operatorID);
    return "";
  }

  function executeTyped(uint256 to) public returns (bytes memory) {
    return execute(abi.encode(to));
  }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";

uint256 constant ID = uint256(keccak256("system.OperatorSet"));

// OperatorSetSystem sets the operator of an owner wallet
// TODO: update operator to autogenerate its ID and maintain an Addr component instead
// once this is done, add a check for the input address not already being assigned to an operator
// and remove the check for the operator already being set for an owner
contract OperatorSetSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    address operator = abi.decode(arguments, (address));
    uint256 ownerID = uint256(uint160(msg.sender));
    uint256 operatorID = LibOperator.getForOwner(components, ownerID);

    require(operatorID == 0, "Operator: already set for owner");

    operatorID = LibOperator.create(components, operator, msg.sender);

    return abi.encode(operatorID);
  }

  function executeTyped(address operator) public returns (bytes memory) {
    return execute(abi.encode(operator));
  }
}

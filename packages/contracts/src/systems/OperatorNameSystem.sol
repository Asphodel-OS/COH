// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.OperatorName"));

// names an existing operator, identified by the calling account
contract OperatorNameSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    string memory name = abi.decode(arguments, (string));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    require(operatorID != 0, "Operator: does not exist");

    LibOperator.setName(components, operatorID, name);
    Utils.updateLastBlock(components, operatorID);
    return "";
  }

  function executeTyped(string memory name) public returns (bytes memory) {
    return execute(abi.encode(name));
  }
}

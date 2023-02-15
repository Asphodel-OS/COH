// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibBattery } from "libraries/LibBattery.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.Init"));

// admin only system to init everything
contract InitSystem is System {
  constructor(IWorld _world, address _components)
    System(_world, _components)
  {}

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    arguments = "";

    initFood();

    return "";
  }

  function executeTyped() public onlyOwner returns (bytes memory) {
    return execute(abi.encode(new bytes(0)));
  }

  function initFood() internal {
    LibBattery.addFoodRegistry(components, world, 10001, 25, "food 1");
    LibBattery.addFoodRegistry(components, world, 10002, 100, "food 2");
    LibBattery.addFoodRegistry(components, world, 10003, 200, "food 3");
  }

}
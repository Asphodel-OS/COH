// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibCoin } from "libraries/LibCoin.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { Strings } from "utils/Strings.sol";

uint256 constant ID = uint256(keccak256("system.ProductionStop"));

// ProductionStopSystem collects and stops an active pet production.
contract ProductionStopSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 charID, uint256 productionID) = abi.decode(arguments, (uint256, uint256));
    uint256 nodeID = LibProduction.getNode(components, productionID);
    // require(LibOperator.getOperator(components, charID) == msg.sender, "Character: not urs");
    require(LibOperator.sharesLocation(components, charID, nodeID), "Node: must be in room");
    require(
      Strings.equal(LibProduction.getState(components, productionID), "ACTIVE"),
      "Production: must be active"
    );

    uint256 amt = LibProduction.calc(components, productionID);
    LibCoin.incBalance(components, charID, amt);
    LibProduction.stop(components, productionID);
    return abi.encode(amt);
  }

  function executeTyped(uint256 charID, uint256 productionID) public returns (bytes memory) {
    return execute(abi.encode(charID, productionID));
  }
}

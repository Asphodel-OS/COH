// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibTrade } from "libraries/LibTrade.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.TradeInitiate"));

// TradeInitiateSystem allows an operator to initiate a trade with another operator, by request
contract TradeInitiateSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    uint256 toID = abi.decode(arguments, (uint256));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    // requirements
    require(operatorID != toID, "Trade: no self-trade !!");
    require(Utils.sameRoom(components, operatorID, toID), "Trade: must be in same room");
    require(LibTrade.getRequest(components, operatorID, toID) == 0, "Trade: request exists");

    uint256 tradeID = LibTrade.create(world, components, operatorID, toID);
    Utils.updateLastBlock(components, operatorID);
    return abi.encode(tradeID);
  }

  function executeTyped(uint256 toID) public returns (bytes memory) {
    return execute(abi.encode(toID));
  }
}

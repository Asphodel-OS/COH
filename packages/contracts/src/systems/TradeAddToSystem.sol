// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibRegister } from "libraries/LibRegister.sol";
import { LibTrade } from "libraries/LibTrade.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.TradeAddTo"));

// TradeAddToSystem allows an operator to add to their register in an ACCEPTED trade
contract TradeAddToSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 tradeID, uint256 itemIndex, uint256 amt) = abi.decode(
      arguments,
      (uint256, uint256, uint256)
    );
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    // requirements
    // TODO: add same room check once disabling of room switching enforced on FE
    // TODO: add restriction from adding to register when already confirmed
    require(Utils.isTrade(components, tradeID), "Trade: not a trade");
    require(LibTrade.hasParticipant(components, tradeID, operatorID), "Trade: must be participant");
    require(Utils.hasState(components, tradeID, "ACCEPTED"), "Trade: must be accepted");

    uint256 registerID = LibRegister.get(components, operatorID, tradeID);
    LibRegister.addTo(world, components, registerID, itemIndex, amt);
    Utils.updateLastBlock(components, operatorID);
    return "";
  }

  function executeTyped(
    uint256 tradeID,
    uint256 itemIndex,
    uint256 amt
  ) public returns (bytes memory) {
    return execute(abi.encode(tradeID, itemIndex, amt));
  }
}

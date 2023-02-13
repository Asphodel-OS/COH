// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibRegister } from "libraries/LibRegister.sol";
import { LibTrade } from "libraries/LibTrade.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.TradeConfirm"));

// TradeConfirmSystem allows an operator to confirm a trade they're currently involved in
contract TradeConfirmSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    uint256 tradeID = abi.decode(arguments, (uint256));
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);

    // requirements
    // TODO: add same room check once disabling of room switching enforced on FE
    require(Utils.isTrade(components, tradeID), "Trade: not a trade");
    require(LibTrade.hasParticipant(components, tradeID, operatorID), "Trade: must be participant");
    require(Utils.hasState(components, tradeID, "ACCEPTED"), "Trade: must be accepted");

    // Set the register to CONFIRMED.
    uint256 registerID = LibRegister.get(components, operatorID, tradeID);
    LibRegister.confirm(components, registerID);

    // Process the trade and mark complete if both parties have confirmed.
    bool tradeComplete;
    if (LibTrade.isDoubleConfirmed(components, tradeID)) {
      tradeComplete = LibTrade.process(world, components, tradeID);
    }

    Utils.updateLastBlock(components, operatorID);
    return abi.encode(tradeComplete);
  }

  function executeTyped(uint256 tradeID) public returns (bytes memory) {
    return execute(abi.encode(tradeID));
  }
}

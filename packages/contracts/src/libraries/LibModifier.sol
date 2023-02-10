// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { ModifierStatusComponent, ID as ModifierStatusComponentID } from "components/ModifierStatusComponent.sol";

enum ModifierStatus {
  INACTIVE,
  ACTIVE
}

library LibModifier {
  ///////////////
  // HOPPERS

  // converts ModifierStatus Enum to Uint256
  function statusToUint256(
    ModifierStatus status
  ) internal pure returns (uint256) {
    return uint256(status);
  }

  // writes status to component from enum
  function writeStatus(
    IUint256Component components,
    uint256 entityID,
    ModifierStatus status
  ) internal {
    ModifierStatusComponent(
      getAddressById(components, ModifierStatusComponentID)
    ).set(entityID, statusToUint256(status));
  }
}
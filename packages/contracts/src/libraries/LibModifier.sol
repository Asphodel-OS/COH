// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibRegistry } from "libraries/LibRegistry.sol";

import { ModifierStatusComponent, ID as ModifierStatusComponentID } from "components/ModifierStatusComponent.sol";
import { ModifierTypeComponent, ID as ModifierTypeComponentID } from "components/ModifierTypeComponent.sol";
import { ModifierValueComponent, ID as ModifierValueComponentID } from "components/ModifierValueComponent.sol";
import { IndexModifierComponent, ID as IndexModifierComponentID } from "components/IndexModifierComponent.sol";
import { IdOwnerComponent, ID as IdOwnerComponentID } from "components/IdOwnerComponent.sol";

import { ID as PrototypeComponentID } from "components/PrototypeComponent.sol";

enum ModStatus {
  NULL,
  INACTIVE,
  ACTIVE
}

enum ModType {
  NULL,
  BASE,
  ADD,
  MUL,
  UMUL
}

library LibModifier {
  ///////////////
  // PETS
  function addToPet(
    IUint256Component components,
    IWorld world,
    uint256 petID,
    uint256 index
  ) internal returns (uint256) {
    uint256 entityID = world.getUniqueEntityId();

    LibRegistry.copyPrototype(
      components,
      IndexModifierComponentID,
      index,
      entityID
    );

    IdOwnerComponent(
      getAddressById(components, IdOwnerComponentID)
    ).set(entityID, petID);
    writeStatus(components, entityID, ModStatus.INACTIVE);
    
    return entityID;
  }

  ///////////////
  // REGISTRY
  function createIndex(
    IUint256Component components,
    IWorld world,
    uint256 index,
    uint256 modValue,
    ModType modType
  ) internal returns (uint256) {
    uint256 entityID = world.getUniqueEntityId();

    uint256[] memory componentIDs = new uint256[](4);
    componentIDs[0] = ModifierValueComponentID;
    componentIDs[1] = ModifierTypeComponentID;
    componentIDs[2] = ModifierStatusComponentID;
    componentIDs[3] = PrototypeComponentID;

    bytes[] memory values = new bytes[](4);
    values[0] = abi.encode(modValue);
    values[1] = abi.encode(modTypeToUint256(modType));
    values[2] = abi.encode(statusToUint256(ModStatus.NULL));
    values[3] = new bytes(0);

    LibRegistry.addPrototype(
      components,
      IndexModifierComponentID,
      index,
      entityID,
      componentIDs,
      values
    );

    return entityID;
  }

  ///////////////
  // QUERY
  // function _getAllX




  ///////////////
  // HOPPERS

  // converts ModStatus Enum to Uint256
  function statusToUint256(
    ModStatus status
  ) internal pure returns (uint256) {
    return uint256(status);
  }

  // writes status to component from enum
  function writeStatus(
    IUint256Component components,
    uint256 entityID,
    ModStatus status
  ) internal {
    ModifierStatusComponent(
      getAddressById(components, ModifierStatusComponentID)
    ).set(entityID, statusToUint256(status));
  }

  // converts ModType Enum to Uint256
  function modTypeToUint256(
    ModType modType
  ) internal pure returns (uint256) {
    return uint256(modType);
  }

  // writes modType to component from enum
  function writeModType(
    IUint256Component components,
    uint256 entityID,
    ModType modType
  ) internal {
    ModifierTypeComponent(
      getAddressById(components, ModifierTypeComponentID)
    ).set(entityID, modTypeToUint256(modType));
  }


}
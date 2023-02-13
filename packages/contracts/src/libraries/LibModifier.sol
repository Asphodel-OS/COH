// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { LibRegistry } from "libraries/LibRegistry.sol";

import { ModifierStatusComponent, ID as ModifierStatusComponentID } from "components/ModifierStatusComponent.sol";
import { ModifierTypeComponent, ID as ModifierTypeComponentID } from "components/ModifierTypeComponent.sol";
import { ModifierValueComponent, ID as ModifierValueComponentID } from "components/ModifierValueComponent.sol";
import { IsModifierComponent, ID as IsModifierComponentID } from "components/IsModifierComponent.sol";
import { IndexModifierComponent, ID as IndexModifierComponentID } from "components/IndexModifierComponent.sol";
import { IdPetComponent, ID as IdPetComponentID } from "components/IdPetComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { ID as PrototypeComponentID } from "components/PrototypeComponent.sol";

import { Strings } from "utils/Strings.sol";

enum ModStatus {
  NULL,
  INACTIVE,
  ACTIVE
}

// enum ModType {
//   NULL,
//   BASE,
//   ADD,
//   MUL,
//   UMUL
// }

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

    LibRegistry.copyPrototype(components, IndexModifierComponentID, index, entityID);

    IdPetComponent(getAddressById(components, IdPetComponentID)).set(entityID, petID);
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
    string memory modType,
    string memory name
  ) internal returns (uint256) {
    uint256 entityID = world.getUniqueEntityId();

    uint256[] memory componentIDs = new uint256[](5);
    componentIDs[0] = ModifierValueComponentID;
    componentIDs[1] = ModifierTypeComponentID;
    componentIDs[2] = ModifierStatusComponentID;
    componentIDs[3] = NameCompID;
    componentIDs[4] = PrototypeComponentID;

    bytes[] memory values = new bytes[](5);
    values[0] = abi.encode(modValue);
    values[1] = abi.encode(modType);
    values[2] = abi.encode(statusToUint256(ModStatus.NULL));
    values[3] = abi.encode(name);
    values[4] = new bytes(0);

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
  function _getAllX(
    IUint256Component components,
    uint256 petID,
    uint256 modIndex,
    ModStatus modStatus,
    string memory modType
  ) internal view returns (uint256[] memory) {
    uint256 numFilters;
    if (petID != 0) numFilters++;
    if (modIndex != 0) numFilters++;
    if (modStatus != ModStatus.NULL) numFilters++;
    if (!Strings.equal(modType, "")) numFilters++;

    QueryFragment[] memory fragments = new QueryFragment[](numFilters + 1);
    fragments[0] = QueryFragment(
      QueryType.Has,
      getComponentById(components, IsModifierComponentID),
      ""
    );

    uint256 filterCount;
    if (petID != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdPetComponentID),
        abi.encode(petID)
      );
    }
    if (modIndex != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IndexModifierComponentID),
        abi.encode(modIndex)
      );
    }
    if (modStatus != ModStatus.NULL) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, ModifierStatusComponentID),
        abi.encode(statusToUint256(modStatus))
      );
    }
    if (!Strings.equal(modType, "")) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, ModifierTypeComponentID),
        abi.encode(modType)
      );
    }

    return LibQuery.query(fragments);
  }

  ///////////////
  // HOPPERS

  // converts ModStatus Enum to Uint256
  function statusToUint256(ModStatus status) internal pure returns (uint256) {
    return uint256(status);
  }

  // writes status to component from enum
  function writeStatus(
    IUint256Component components,
    uint256 entityID,
    ModStatus status
  ) internal {
    ModifierStatusComponent(getAddressById(components, ModifierStatusComponentID)).set(
      entityID,
      statusToUint256(status)
    );
  }
}

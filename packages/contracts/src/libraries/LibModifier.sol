// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { LibRegistry } from "libraries/LibRegistry.sol";
import { LibPrototype } from "libraries/LibPrototype.sol";

import { IdPetComponent, ID as IdPetComponentID } from "components/IdPetComponent.sol";
import { IndexModifierComponent, ID as IndexModifierComponentID } from "components/IndexModifierComponent.sol";
import { IsModifierComponent, ID as IsModifierComponentID } from "components/IsModifierComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { StatusComponent, ID as StatusComponentID } from "components/StatusComponent.sol";
import { TypeComponent, ID as TypeComponentID } from "components/TypeComponent.sol";
import { ValueComponent, ID as ValueComponentID } from "components/ValueComponent.sol";
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

  // sets at active
  function addToPet(
    IUint256Component components,
    IWorld world,
    uint256 petID,
    uint256 index
  ) internal returns (uint256) {
    uint256 entityID = world.getUniqueEntityId();

    LibRegistry.copyPrototype(components, IndexModifierComponentID, index, entityID);

    IdPetComponent(getAddressById(components, IdPetComponentID)).set(entityID, petID);
    writeStatus(components, entityID, ModStatus.ACTIVE);

    return entityID;
  }

  function remove(IUint256Component components, uint256 entityID) internal {
    LibPrototype.remove(components, entityID);
    IdPetComponent(getAddressById(components, IdPetComponentID)).remove(entityID);
  }

  function setActive(IUint256Component components, uint256 entityID) internal {
    writeStatus(components, entityID, ModStatus.ACTIVE);
  }

  function setInactive(IUint256Component components, uint256 entityID) internal {
    writeStatus(components, entityID, ModStatus.INACTIVE);
  }

  //////////////////
  // CALCULATION

  // calculates bandwidth and storage from array
  // returns (bandwidth, storageSize)
  // ap: this design choice makes it impractical to do regular querying
  //     better for fe retrieval but need dreaded array operations
  function calcArray(
    IUint256Component components,
    uint256 baseValue,
    uint256[] memory arr
  ) internal view returns (uint256 bandwidth, uint256 storageSize) {
    // assumes all components in array is activated
    uint256 store;
    uint256 add;
    uint256 mul = 100;
    uint256 umul = 100;

    for (uint256 i; i < arr.length; i++) {
      if (arr[i] == 0) continue;

      uint256 val = getValue(components, arr[i]);
      string memory modType = getType(components, arr[i]);

      if (Strings.equal(modType, "ADD")) {
        add = add + val;
      } else if (Strings.equal(modType, "MUL")) {
        // value is a %
        mul = (mul * (100 + val)) / 100;
      } else if (Strings.equal(modType, "UMUL")) {
        // value is a %
        umul = (umul * (100 + val)) / 100;
      } else if (Strings.equal(modType, "STORAGE")) {
        store = store + val;
      } else {
        require(false, "unspecified mod type");
      }
    }

    // if baseValue is 0, can assume this is calculating for base value
    if (baseValue > 0) {
      bandwidth = ((((baseValue * mul) / 100) + add) * umul) / 100;
    } else {
      bandwidth = (add * mul * umul) / 10000;
    }

    storageSize = store;
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

    uint256[] memory componentIDs = new uint256[](6);
    componentIDs[0] = ValueComponentID;
    componentIDs[1] = TypeComponentID;
    componentIDs[2] = StatusComponentID;
    componentIDs[3] = NameCompID;
    componentIDs[4] = IndexModifierComponentID;
    componentIDs[5] = PrototypeComponentID;

    bytes[] memory values = new bytes[](6);
    values[0] = abi.encode(modValue);
    values[1] = abi.encode(modType);
    values[2] = abi.encode(statusToUint256(ModStatus.NULL));
    values[3] = abi.encode(name);
    values[4] = abi.encode(index);
    values[5] = new bytes(0);

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

  /////////////////
  // COMPONENT RETRIEVAL
  function getType(IUint256Component components, uint256 id) internal view returns (string memory) {
    return TypeComponent(getAddressById(components, TypeComponentID)).getValue(id);
  }

  function getValue(IUint256Component components, uint256 id) internal view returns (uint256) {
    return ValueComponent(getAddressById(components, ValueComponentID)).getValue(id);
  }

  function getIndex(IUint256Component components, uint256 id) internal view returns (uint256) {
    return
      IndexModifierComponent(getAddressById(components, IndexModifierComponentID)).getValue(id);
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
        getComponentById(components, StatusComponentID),
        abi.encode(statusToUint256(modStatus))
      );
    }
    if (!Strings.equal(modType, "")) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, TypeComponentID),
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
    StatusComponent(getAddressById(components, StatusComponentID)).set(
      entityID,
      statusToUint256(status)
    );
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById, entityToAddress, addressToEntity } from "solecs/utils.sol";

import { HashRateComponent, ID as HashRateCompID } from "components/HashRateComponent.sol";
import { MediaURIComponent, ID as MediaURICompID } from "components/MediaURIComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { PetTraitsEquippedComponent, ID as PetTraitsEquippedCompID } from "components/PetTraitsEquippedComponent.sol";
import { PetTraitsPermanentComponent, ID as PetTraitsPermanentCompID } from "components/PetTraitsPermanentComponent.sol";
import { StorageSizeComponent, ID as StorSizeCompID } from "components/StorageSizeComponent.sol";

import { LibModifier } from "libraries/LibModifier.sol";

// import { console } from "forge-std/console.sol";

library LibPetTraits {
  // hardcoded placeholder, fake registry
  function placeholderRegistry(IUintComp components, IWorld world) internal {
    // set 100-106, equippable
    LibModifier.createIndex(
      components,
      world,
      101, // index
      11, // modValue
      "ADD", // modType
      "Pickaxe" // name
    );
    LibModifier.createIndex(
      components,
      world,
      102, // index
      22, // modValue
      "STORAGE", // modType
      "Bagpack" // name
    );
    LibModifier.createIndex(
      components,
      world,
      103, // index
      33, // modValue
      "ADD", // modType
      "Gloves" // name
    );
    LibModifier.createIndex(
      components,
      world,
      104, // index
      44, // modValue
      "MUL", // modType
      "Persona" // name
    );
    LibModifier.createIndex(
      components,
      world,
      105, // index
      55, // modValue
      "STORAGE", // modType
      "Pockets" // name
    );
    LibModifier.createIndex(
      components,
      world,
      106, // index
      66, // modValue
      "UMUL", // modType
      "PowerOfFriendship" // name
    );

    // 1 - 6, permanent body traits
    LibModifier.createIndex(
      components,
      world,
      1, // index
      1, // modValue
      "MUL", // modType
      "Color" // name
    );
    LibModifier.createIndex(
      components,
      world,
      2, // index
      2, // modValue
      "ADD", // modType
      "Body" // name
    );
    LibModifier.createIndex(
      components,
      world,
      3, // index
      3, // modValue
      "STORAGE", // modType
      "Hand" // name
    );
    LibModifier.createIndex(
      components,
      world,
      4, // index
      4, // modValue
      "MUL", // modType
      "Eyes" // name
    );
    LibModifier.createIndex(
      components,
      world,
      5, // index
      5, // modValue
      "STORAGE", // modType
      "Mouth" // name
    );
    LibModifier.createIndex(
      components,
      world,
      6, // index
      6, // modValue
      "ADD", // modType
      "Background" // name
    );
  }

  function placeholderTraits(
    IUintComp components,
    IWorld world,
    uint256 entityID
  ) internal {
    // perm
    uint256[] memory arrPerm = new uint256[](6);
    for (uint256 i; i < arrPerm.length; i++) {
      arrPerm[i] = LibModifier.addToPet(components, world, entityID, i + 1);
    }

    PetTraitsPermanentComponent(getAddressById(components, PetTraitsPermanentCompID)).set(
      entityID,
      arrPerm
    );

    // equipped
    uint256[] memory arrEquip = new uint256[](6);
    for (uint256 i; i < arrEquip.length; i++) {
      arrEquip[i] = LibModifier.addToPet(components, world, entityID, 100 + i + 1);
    }

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(
      entityID,
      arrEquip
    );
  }
}

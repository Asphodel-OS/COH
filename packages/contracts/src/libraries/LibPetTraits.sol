// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById, entityToAddress, addressToEntity } from "solecs/utils.sol";

import { BandwidthComponent, ID as BandwidthCompID } from "components/BandwidthComponent.sol";
import { MediaURIComponent, ID as MediaURICompID } from "components/MediaURIComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { PetTraitsEquippedComponent, ID as PetTraitsEquippedCompID } from "components/PetTraitsEquippedComponent.sol";
import { PetTraitsPermanentComponent, ID as PetTraitsPermanentCompID } from "components/PetTraitsPermanentComponent.sol";
import { StorageSizeComponent, ID as StorageSizeCompID } from "components/StorageSizeComponent.sol";

import { LibModifier } from "libraries/LibModifier.sol";
import { LibInventory } from "libraries/LibInventory.sol";

// import { console } from "forge-std/console.sol";

uint256 constant PERM_LENGTH = 6;
uint256 constant EQUIP_LENGTH = 6;
uint256 constant SLOT_A = 0;
uint256 constant SLOT_B = 1;

library LibPetTraits {
  ///////////////
  // MINTING

  function setPermTraits(
    IUintComp components,
    IWorld world,
    uint256 entityID,
    uint256[] memory registryIDs
  ) internal {
    require(registryIDs.length == PERM_LENGTH, "wrong num base traits");

    uint256[] memory arr = new uint256[](PERM_LENGTH);
    for (uint256 i; i < arr.length; i++) {
      arr[i] = LibModifier.addToPet(components, world, entityID, registryIDs[i]);
    }

    PetTraitsPermanentComponent(getAddressById(components, PetTraitsPermanentCompID)).set(
      entityID,
      arr
    );
  }

  // force sets to [SLOT_A, SLOT_B, mod slots]
  function setTempTraits(
    IUintComp components,
    IWorld world,
    uint256 entityID,
    uint256 slotA,
    uint256 slotB,
    uint256[] memory modSlots
  ) internal {
    // change this for customisable max
    require(modSlots.length + 2 <= EQUIP_LENGTH, "wrong num equip traits");

    uint256[] memory arr = new uint256[](modSlots.length + 2);
    arr[0] = LibModifier.addToPet(components, world, entityID, slotA);
    arr[1] = LibModifier.addToPet(components, world, entityID, slotB);
    for (uint256 i = 2; i < arr.length; i++) {
      arr[i] = LibModifier.addToPet(components, world, entityID, modSlots[i]);
    }

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(
      entityID,
      arr
    );
  }

  ///////////////
  // CAL

  function updateValues(IUintComp components, uint256 petID)
    internal
    returns (uint256 hashrate, uint256 storageSize)
  {
    uint256[] memory perms = PetTraitsPermanentComponent(
      getAddressById(components, PetTraitsPermanentCompID)
    ).getValue(petID);

    uint256 tempStore;
    (hashrate, tempStore) = LibModifier.calArray(components, 0, perms);

    uint256[] memory equips = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    (hashrate, storageSize) = LibModifier.calArray(components, hashrate, equips);
    storageSize = storageSize + tempStore;

    BandwidthComponent(getAddressById(components, BandwidthCompID)).set(petID, hashrate);
    StorageSizeComponent(getAddressById(components, StorageSizeCompID)).set(petID, storageSize);
  }

  ///////////////
  // SWAPPING

  function swapSlotA(
    IUintComp components,
    uint256 petID,
    uint256 slot
  ) internal returns (uint256 removed) {
    uint256[] memory arr = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    if (arr[SLOT_A] != 0) {
      removed = arr[SLOT_A];
      LibModifier.setInactive(components, arr[SLOT_A]);
    }
    arr[SLOT_A] = slot;
    LibModifier.setActive(components, slot);

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(petID, arr);
  }

  function swapSlotB(
    IUintComp components,
    uint256 petID,
    uint256 slot
  ) internal returns (uint256 removed) {
    uint256[] memory arr = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    if (arr[SLOT_B] != 0) {
      removed = arr[SLOT_B];
      LibModifier.setInactive(components, arr[SLOT_B]);
    }
    arr[SLOT_B] = slot;
    LibModifier.setActive(components, slot);

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(petID, arr);
  }

  // swaps a mod slot. returns false if no swap
  function swapModSlot(
    IUintComp components,
    uint256 petID,
    uint256 mod
  ) internal returns (bool) {
    uint256[] memory arr = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    for (uint256 i = 2; i < arr.length; i++) {
      if (arr[i] == mod) {
        // replace mod, will never replace a 0 mod
        LibModifier.setInactive(components, arr[i]);
        arr[i] = mod;
        LibModifier.setActive(components, mod);

        PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(
          petID,
          arr
        );

        return true;
      }
    }

    return false;
  }

  // only do 1 by 1
  function addModSlot(
    IUintComp components,
    uint256 petID,
    uint256 mod
  ) internal returns (bool) {
    uint256[] memory arr = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    require(arr.length < EQUIP_LENGTH, "max equip length");

    uint256[] memory result = new uint256[](arr.length + 1);
    for (uint256 i; i < arr.length; i++) {
      if (arr[i] == mod) {
        // returns false if mod is already installed
        return false;
      }
      result[i] = arr[i];
    }

    result[arr.length] = mod;

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(
      petID,
      result
    );

    return true;
  }

  function removeModSlot(
    IUintComp components,
    uint256 petID,
    uint256 mod
  ) internal returns (bool removed) {
    uint256[] memory arr = PetTraitsEquippedComponent(
      getAddressById(components, PetTraitsEquippedCompID)
    ).getValue(petID);

    require(arr.length > 2, "min equip length");

    uint256[] memory result = new uint256[](arr.length - 1);
    for (uint256 i = 2; i < result.length; i++) {
      if (arr[i] == mod) {
        // returns true if removed
        LibModifier.setInactive(components, arr[i]);
        result[i] = arr[arr.length - 1];
        removed = true;
      } else {
        result[i] = arr[i];
      }
    }

    PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).set(
      petID,
      result
    );

    return removed;
  }

  //////////////////
  // Multi-invenotry bridge
  // INVARIENT: item and modifier IDs are the same

  // removes mod from inventor active
  // creates mod entity, removes balance
  function invToMod(
    IUintComp components,
    IWorld world,
    uint256 petID,
    uint256 operatorID,
    uint256 mod
  ) internal returns (uint256) {
    // get item inventory
    uint256 invID = LibInventory.get(components, operatorID, mod);
    require(invID != 0, "no inventory");
    LibInventory.dec(components, invID, 1);

    // create and set entity
    return LibModifier.addToPet(components, world, petID, mod);
  }

  // deletes mod item and adds to inv
  function modToInv(
    IUintComp components,
    IWorld world,
    uint256 petID,
    uint256 operatorID,
    uint256 modID
  ) internal {
    // get mod index
    uint256 modIndex = LibModifier.getIndex(components, modID);

    // delete entry
    LibModifier.remove(components, modID);

    // get item inventory
    uint256 invID = LibInventory.get(components, operatorID, modIndex);
    if (invID == 0) invID = LibInventory.create(world, components, petID, modIndex);
    LibInventory.inc(components, invID, 1);
  }

  ///////////////////
  // GETTERS

  // gets array of permanent traits
  function getPermArray(IUintComp components, uint256 petID)
    internal
    view
    returns (uint256[] memory)
  {
    // traits are arranged in fixed order
    return
      PetTraitsPermanentComponent(getAddressById(components, PetTraitsPermanentCompID)).getValue(
        petID
      );
  }

  function getEquipArray(IUintComp components, uint256 petID)
    internal
    view
    returns (uint256[] memory)
  {
    return
      PetTraitsEquippedComponent(getAddressById(components, PetTraitsEquippedCompID)).getValue(
        petID
      );
  }

  function getName(IUintComp components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  // get names of attached modifiers from array. Assume all have names
  function getNames(IUintComp components, uint256[] memory arr)
    internal
    view
    returns (string[] memory)
  {
    string[] memory result = new string[](arr.length);
    for (uint256 i; i < arr.length; i++) {
      result[i] = getName(components, arr[i]);
    }
    return result;
  }

  ///////////////////
  // HARDCODE PLACEHOLDER, leaving here for now
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

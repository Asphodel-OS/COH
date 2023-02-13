// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibPet } from "libraries/LibPet.sol";
import { LibPetTraits } from "libraries/LibPetTraits.sol";
import { Strings } from "utils/Strings.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.Pet.EquipModifierSystem"));

// EquipModifierPetSystem changes the pet's currently equipped array at one go
contract EquipModifierPetSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (
      uint256 petID, 
      uint256 IdSlotA, 
      uint256 IdSlotB,
      uint256[] memory IdToAdd,
      uint256[] memory toRemove
    ) = abi.decode(arguments, (uint256, uint256, uint256, uint256[], uint256[]));

    uint256 operatorID = uint256(uint160(msg.sender));
    require(LibPet.getOperator(components, petID) == operatorID, "Pet: not urs");

    // swaps slotA if not 0
    if (IdSlotA != 0) {
      uint256 removed = LibPetTraits.swapSlotA(components, petID, IdSlotA);
      if (removed != 0) {
        LibPetTraits.modToInv(components, world, petID, operatorID, removed);
      }
    }
    // swap slotB if not 0
    if (IdSlotB != 0) {
      uint256 removed = LibPetTraits.swapSlotB(components, petID, IdSlotB);
      if (removed != 0) {
        LibPetTraits.modToInv(components, world, petID, operatorID, removed);
      }
    }

    // remove all to be removed
    for (uint256 i; i < toRemove.length; i++) {
      LibPetTraits.removeModSlot(components, petID, toRemove[i]);
      LibPetTraits.modToInv(components, world, petID, operatorID, toRemove[i]);
    }

    // add all toAdd
    for (uint256 i; i < IdToAdd.length; i++) {
      uint256 toAdd = LibPetTraits.invToMod(components, world, petID, operatorID, IdToAdd[i]);
      LibPetTraits.addModSlot(components, petID, toAdd);
    }

    Utils.updateLastBlock(components, operatorID);
    return "";
  }

  function executeTyped(
    uint256 petID,
    uint256 slotA,
    uint256 slotB,
    uint256[] memory toAdd,
    uint256[] memory toRemove
  ) public returns (bytes memory) {
    return execute(abi.encode(petID, slotA, slotB, toAdd, toRemove));
  }
}

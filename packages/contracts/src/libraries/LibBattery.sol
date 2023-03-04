// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById, entityToAddress, addressToEntity } from "solecs/utils.sol";
import { LibString } from "solady/utils/LibString.sol";

// TODO: change ModReg to ItemReg. also implement ItemReg
import { LibRegistry as LibModReg } from "libraries/LibRegistry.sol";

import { CapacityComponent, ID as CapacityCompID } from "components/CapacityComponent.sol";
import { ChargeComponent, ID as ChargeCompID } from "components/ChargeComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionCompID } from "components/TimeLastActionComponent.sol";
import { BalanceComponent, ID as BalanceCompID } from "components/BalanceComponent.sol";
import { IsFoodComponent, ID as IsFoodCompID } from "components/IsFoodComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { ID as IndexItemCompID } from "components/IndexItemComponent.sol";

// at 150 points, 25h irl. shorten for demo
// uint256 constant epoch = 10 minutes;
uint256 constant epoch = 1 seconds; // 2.5 min cycle for demo

// library for all things battery related! interwoven with LibPet
library LibBattery {
  ///////////////////
  // CAL

  // capacity is held as an arbituary value, no units
  // e.g. cap = 150, epoch = 10 mins,
  //      cur = 150 * timeSinceCharge (min) / 10 (min)
  // use charge to calculate, capacity is *max charge*
  function cal(IUintComp components, uint256 petID) internal view returns (uint256) {
    uint256 charge = getCharge(components, petID);
    uint256 lastChar = getLastCharge(components, petID);

    // amount of charge that should be used
    // (time diff) * 10 minutes
    uint256 charUsed = (block.timestamp - lastChar) / epoch;

    if (charUsed >= charge) {
      // used up all charge, out of battery
      return 0;
    }

    return charge - charUsed;
  }

  // returns true if still alive
  function hasCharge(IUintComp components, uint256 petID) internal view returns (bool) {
    return cal(components, petID) == 0;
  }

  // eat food, update charge
  function chargeBat(
    IUintComp components,
    uint256 petID,
    uint256 toAdd
  ) internal {
    uint256 capacity = getCapacity(components, petID);
    uint256 cur = cal(components, petID);

    if (capacity < cur + toAdd) {
      setCharge(components, petID, capacity);
    } else {
      setCharge(components, petID, cur + toAdd);
    }

    setLastCharge(components, petID, block.timestamp);
  }

  ///////////////////
  // FOOD nom nom

  // adds a food item to registry
  function addFoodRegistry(
    IUintComp components,
    IWorld world,
    uint256 index,
    uint256 value,
    string memory name
  ) internal {
    uint256 entityID = world.getUniqueEntityId();

    IsFoodComponent(getAddressById(components, IsFoodCompID)).set(entityID);
    BalanceComponent(getAddressById(components, BalanceCompID)).set(entityID, value);
    NameComponent(getAddressById(components, NameCompID)).set(entityID, name);

    LibModReg.add(components, IndexItemCompID, index, entityID);
  }

  function getFoodValue(IUintComp components, uint256 index) internal view returns (uint256) {
    // no additional check for isFood, but does not affect
    uint256 entityID = LibModReg.get(components, IndexItemCompID, index);
    return BalanceComponent(getAddressById(components, BalanceCompID)).getValue(entityID);
  }

  ///////////////////
  // GETTERS
  function getCapacity(IUintComp components, uint256 petID) internal view returns (uint256) {
    return CapacityComponent(getAddressById(components, CapacityCompID)).getValue(petID);
  }

  function getCharge(IUintComp components, uint256 petID) internal view returns (uint256) {
    return ChargeComponent(getAddressById(components, ChargeCompID)).getValue(petID);
  }

  function getLastCharge(IUintComp components, uint256 petID) internal view returns (uint256) {
    return
      TimeLastActionComponent(getAddressById(components, TimeLastActionCompID)).getValue(petID);
  }

  ///////////////////
  // SETTERS
  function setCapacity(
    IUintComp components,
    uint256 petID,
    uint256 value
  ) internal {
    CapacityComponent(getAddressById(components, CapacityCompID)).set(petID, value);
  }

  function setCharge(
    IUintComp components,
    uint256 petID,
    uint256 value
  ) internal {
    ChargeComponent(getAddressById(components, ChargeCompID)).set(petID, value);
  }

  function setLastCharge(
    IUintComp components,
    uint256 petID,
    uint256 value
  ) internal {
    TimeLastActionComponent(getAddressById(components, TimeLastActionCompID)).set(petID, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Uint256Component } from "std-contracts/components/Uint256Component.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibPrototype } from "libraries/LibPrototype.sol";

library LibRegistry {
  // returns entity at registry
  function get(
    IUint256Component components,
    uint256 registryID,
    uint256 index
  ) internal view returns (uint256) {
    IUint256Component comp = IUint256Component(getAddressById(components, registryID));

    uint256[] memory results = comp.getEntitiesWithValue(index);

    require(results.length == 1, "index does not exist in registry");
    // hardcoded to first index. should not create multiple indexes with same id
    // create custom component for this?
    return results[0];
  }

  function add(
    IUint256Component components,
    uint256 registryID,
    uint256 index,
    uint256 entityToAdd
  ) internal {
    Uint256Component comp = Uint256Component(getAddressById(components, registryID));

    require(comp.getEntitiesWithValue(index).length == 0, "already has index");

    comp.set(entityToAdd, index);
  }

  function addPrototype(
    IUint256Component components,
    uint256 registryID,
    uint256 index,
    uint256 entityToAdd,
    uint256[] memory componentIDs,
    bytes[] memory values
  ) internal {
    // creates prototype and assigns it a registryID
    LibPrototype.create(components, entityToAdd, componentIDs, values);

    add(compoents, registryID, index, entityToAdd);
  }

  function copyPrototype(
    IUint256Component components,
    uint256 registryID,
    uint256 index,
    uint256 entityID
  ) internal {
    uint256 prototypeID = get(components, registryID, index);

    LibPrototype.copy(components, entityID, prototypeID);
  }
}

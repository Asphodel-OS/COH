// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { PrototypeComponent, ID as PrototypeComponentID } from "components/PrototypeComponent.sol";

library LibPrototype {
  // creates a new prototype
  function create(
    IUint256Component components,
    uint256 entityID,
    uint256[] memory componentIDs,
    bytes[] memory values
  ) internal returns (uint256) {
    // does not add prototypeComponent! put bytes(0) for prototype
    require(componentIDs.length == values.length, "LibPrototype: values diff length");

    PrototypeComponent(getAddressById(components, PrototypeComponentID)).set(
      entityID,
      componentIDs
    );

    for (uint256 i; i < componentIDs.length; i++) {
      if (componentIDs[i] == PrototypeComponentID) {
        PrototypeComponent c = PrototypeComponent(getAddressById(components, PrototypeComponentID));
        c.set(entityID, componentIDs);
      } else {
        IComponent c = IComponent(getAddressById(components, componentIDs[i]));
        c.set(entityID, values[i]);
      }
    }

    return entityID;
  }

  // copies an existing prototype
  function copy(
    IUint256Component components,
    uint256 entityID,
    uint256 prototypeID
  ) internal returns (uint256) {
    require(
      PrototypeComponent(getAddressById(components, PrototypeComponentID)).has(prototypeID),
      "Trying to copy non-existing prototype"
    );

    uint256[] memory prototypeComponents = PrototypeComponent(
      getAddressById(components, PrototypeComponentID)
    ).getValue(prototypeID);
    for (uint256 i; i < prototypeComponents.length; i++) {
      IComponent c = IComponent(getAddressById(components, prototypeComponents[i]));
      c.set(entityID, c.getRawValue(prototypeID));
    }

    // not strictly needed ig
    return entityID;
  }

  function remove(IUint256Component components, uint256 entityID) internal {
    require(
      PrototypeComponent(getAddressById(components, PrototypeComponentID)).has(entityID),
      "Trying to delete non-existing prototype"
    );

    uint256[] memory componentIDs = PrototypeComponent(
      getAddressById(components, PrototypeComponentID)
    ).getValue(entityID);

    for (uint256 i; i < componentIDs.length; i++) {
      IComponent c = IComponent(getAddressById(components, componentIDs[i]));
      c.remove(entityID);
    }
  }
}

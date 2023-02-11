// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IsOperatorComponent, ID as IsOperatorCompID } from "components/IsOperatorComponent.sol";
import { LocationComponent, ID as LocCompID } from "components/LocationComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionComponentID } from "components/TimeLastActionComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { LibRoom } from "libraries/LibRoom.sol";

library LibOperator {
  // Create an account operator
  function create(IComponents components, address addr) internal returns (uint256) {
    uint256 id = uint256(uint160(addr));
    IsOperatorComponent(getAddressById(components, IsOperatorCompID)).set(id);
    LocationComponent(getAddressById(components, LocCompID)).set(id, 1);
    return id;
  }

  // Move the Address to a room
  function move(
    IComponents components,
    uint256 id,
    uint256 to
  ) internal {
    LocationComponent(getAddressById(components, LocCompID)).set(id, to);
    updateLastTimestamp(components, id);
  }

  // Update the TimeLastAction of the character to the current time.
  function updateLastTimestamp(IComponents components, uint256 id) internal {
    TimeLastActionComponent(getAddressById(components, TimeLastActionComponentID)).set(
      id,
      block.timestamp
    );
  }

  /////////////////
  // CALCULATIONS

  // Check whether a character can move to a location from where they currently are.
  // This function assumes that the entity id provided belongs to a character.
  // NOTE(ja): This function can include any other checks we want moving forward.
  function canMoveTo(
    IComponents components,
    uint256 id,
    uint256 to
  ) internal view returns (bool) {
    uint256 from = getLocation(components, id);
    return LibRoom.isValidPath(components, from, to);
  }

  /////////////////
  // CHECKS

  // determines whether an entity shares a location with a node
  function sharesLocation(
    IComponents components,
    uint256 id,
    uint256 entityID
  ) internal view returns (bool) {
    LocationComponent LocC = LocationComponent(getAddressById(components, LocCompID));
    return LocC.getValue(id) == LocC.getValue(entityID);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  // get the operating wallet of a specified pet
  function getAddress(uint256 id) internal pure returns (address) {
    return address(uint160(id));
  }

  // gets the location of a specified account operator
  function getLocation(IComponents components, uint256 id) internal view returns (uint256) {
    return LocationComponent(getAddressById(components, LocCompID)).getValue(id);
  }
}

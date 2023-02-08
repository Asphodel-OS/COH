// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { ID as IsCharacterComponentID } from "components/IsCharacterComponent.sol";
import { LocationComponent, ID as LocCompID } from "components/LocationComponent.sol";
import { OperatorComponent, ID as OperatorCompID } from "components/OperatorComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionComponentID } from "components/TimeLastActionComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { LibRoom } from "libraries/LibRoom.sol";

// NOTE(ja): thinking we should handle minting and location movements here as well. It would be
// good to standardize our libraries to operate around a specific object or set of objects
library LibCharacter {
  // // Create a character from an existing NFT. We should migrate ERC721 ownership checks here if possible
  // function register() internal {}

  // Move a character to a room
  function move(
    IUint256Component components,
    uint256 id,
    uint256 to
  ) internal {
    LocationComponent(getAddressById(components, LocCompID)).set(id, to);
    updateLastTimestamp(components, id);
  }

  // Update the TimeLastAction of the character to the current time.
  function updateLastTimestamp(IUint256Component components, uint256 id) internal {
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
    IUint256Component components,
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
    IUint256Component components,
    uint256 id,
    uint256 entityID
  ) internal view returns (bool) {
    LocationComponent LocC = LocationComponent(getAddressById(components, LocCompID));
    return LocC.getValue(id) == LocC.getValue(entityID);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  // gets the location of a specified character
  function getLocation(IUint256Component components, uint256 id) internal view returns (uint256) {
    return LocationComponent(getAddressById(components, LocCompID)).getValue(id);
  }

  // get the operating wallet of a specified character
  function getOperator(IUint256Component components, uint256 charID)
    internal
    view
    returns (address)
  {
    return OperatorComponent(getAddressById(components, OperatorCompID)).getValue(charID);
  }

  /////////////////
  // QUERIES

  // Get the active productions of a character on a node. Return 0 if there are none.
  function getActiveNodeProduction(
    IUint256Component components,
    uint256 id,
    uint256 nodeID
  ) internal view returns (uint256 result) {
    uint256[] memory results = LibProduction._getAllX(components, nodeID, id, 0, "");
    if (results.length > 0) {
      result = results[0];
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { ID as IsCharacterComponentID } from "components/IsCharacterComponent.sol";
import { ExitsComponent, ID as ExitsComponentID } from "components/ExitsComponent.sol";
import { LocationComponent, ID as LocationComponentID } from "components/LocationComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionComponentID } from "components/TimeLastActionComponent.sol";
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
    isCharacter(components, id);
    LocationComponent(getAddressById(components, LocationComponentID)).set(id, to);
  }

  // Check whether an entity is a Character.
  function isCharacter(IUint256Component components, uint256 id) internal view returns (bool) {
    return getComponentById(components, IsCharacterComponentID).has(id);
  }

  // Check whether a character can move to a location from where they currently are.
  // This function assumes that the entity id provided belongs to a character.
  // NOTE(ja): This function can include any other checks we want moving forward.
  function canMoveTo(
    IUint256Component components,
    uint256 id,
    uint256 to
  ) internal view returns (bool) {
    uint256 from = LocationComponent(getAddressById(components, LocationComponentID)).getValue(id);
    return LibRoom.isValidPath(components, from, to);
  }

  // Update the TimeLastAction of the character to the current time.
  function updateLastTimestamp(IUint256Component components, uint256 id) internal {
    TimeLastActionComponent(getAddressById(components, TimeLastActionComponentID)).set(
      id,
      block.timestamp
    );
  }
}

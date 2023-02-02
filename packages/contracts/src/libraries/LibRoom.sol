// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById } from "solecs/utils.sol";

import { ExitsComponent, ID as ExitsComponentID } from "components/ExitsComponent.sol";
import { LocationComponent, ID as LocationComponentID } from "components/LocationComponent.sol";
import { RoomComponent, ID as RoomComponentID } from "components/RoomComponent.sol";

library LibRoom {
  // Create a room at a given location.
  function create(
    IWorld world,
    IUint256Component components,
    uint256 location
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    RoomComponent(getAddressById(components, RoomComponentID)).set(id);
    LocationComponent(getAddressById(components, LocationComponentID)).set(id, location);
    return id;
  }

  // Retrieve the ID of a room with the given location.
  function get(IUint256Component components, uint256 location)
    internal
    view
    returns (uint256 result)
  {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(
      QueryType.Has,
      IComponent(getAddressById(components, RoomComponentID)),
      ""
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      IComponent(getAddressById(components, LocationComponentID)),
      abi.encode(location)
    );

    uint256[] memory results = LibQuery.query(fragments);
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get all the possible exits of a given room.
  function getExits(IUint256Component components, uint256 id)
    internal
    view
    returns (uint256[] memory)
  {
    return ExitsComponent(getAddressById(components, ExitsComponentID)).getValue(id);
  }

  // Checks whether an entity can move 'from' a location 'to' a location.
  function isValidPath(
    IUint256Component components,
    uint256 from,
    uint256 to
  ) internal view returns (bool can) {
    uint256 fromRoomID = get(components, from);
    uint256[] memory exits = getExits(components, fromRoomID);

    for (uint256 i; i < exits.length; i++) {
      if (exits[i] == to) {
        can = true;
      }
    }
  }

  // function getAll() internal view returns (uint256[] memory) {}
}

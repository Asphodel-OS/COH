// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById, addressToEntity } from "solecs/utils.sol";

import { IdOwnerComponent, ID as IdOwnerCompID } from "components/IdOwnerComponent.sol";
import { IsOperatorComponent, ID as IsOperatorCompID } from "components/IsOperatorComponent.sol";
import { BlockLastComponent, ID as BlockLastCompID } from "components/BlockLastComponent.sol";
import { LocationComponent, ID as LocCompID } from "components/LocationComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";
import { LibRoom } from "libraries/LibRoom.sol";

library LibOperator {
  /////////////////
  // INTERACTIONS

  // Create an account operator
  function create(
    IComponents components,
    address addr,
    address owner
  ) internal returns (uint256) {
    uint256 id = uint256(uint160(addr));
    IsOperatorComponent(getAddressById(components, IsOperatorCompID)).set(id);
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, addressToEntity(owner));
    LocationComponent(getAddressById(components, LocCompID)).set(id, 1);
    return id;
  }

  function change(
    IComponents components,
    address addr, 
    address owner
  ) internal returns (uint256) {
    uint256 id = uint256(uint160(addr));
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, addressToEntity(owner));
    return id;
  }

  // Move the Address to a room
  function move(
    IComponents components,
    uint256 id,
    uint256 to
  ) internal {
    LocationComponent(getAddressById(components, LocCompID)).set(id, to);
    updateLastActionBlock(components, id);
  }

  // Update the BlockLast of the character to the current time.
  function updateLastActionBlock(IComponents components, uint256 id) internal {
    BlockLastComponent(getAddressById(components, BlockLastCompID)).set(id, block.number);
  }

  /////////////////
  // CHECKS

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

  // determines whether an entity shares a location with a node
  // TODO: this is already generalized, move to shared library?
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

  // gets the location of a specified account operator
  function getOwner(IComponents components, uint256 id) internal view returns (uint256) {
    return IdOwnerComponent(getAddressById(components, IdOwnerCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get the operator of an owner
  function getForOwner(IComponents components, uint256 ownerID)
    internal
    view
    returns (uint256 result)
  {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsOperatorCompID), "");
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdOwnerCompID),
      abi.encode(ownerID)
    );

    uint256[] memory results = LibQuery.query(fragments);
    if (results.length > 0) {
      result = results[0];
    }
  }
}

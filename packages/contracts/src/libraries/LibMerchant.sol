// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IsMerchantComponent, ID as IsMerchantCompID } from "components/IsMerchantComponent.sol";
import { LocationComponent, ID as LocationCompID } from "components/LocationComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { Strings } from "utils/Strings.sol";

/*
 * LibMerchant handles all operations interacting with Merchants
 */
library LibMerchant {
  // create a merchant entity as specified
  function create(
    IWorld world,
    IComponents components,
    uint256 location,
    string memory name
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsMerchantComponent(getAddressById(components, IsMerchantCompID)).set(id);
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
    LocationComponent(getAddressById(components, LocationCompID)).set(id, location);
    return id;
  }

  /////////////////
  // COMPONENT RETRIEVAL

  // gets the name of a specified merchant
  function getName(IComponents components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get a specified merchant by location. return only the first result
  function getAtLocation(IComponents components, uint256 location)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = _getAllX(components, location, "");
    if (results.length != 0) {
      result = results[0];
    }
  }

  // Retrieves all listingsbased on any defined filters
  function _getAllX(
    IComponents components,
    uint256 location,
    string memory name
  ) internal view returns (uint256[] memory) {
    uint256 numFilters;
    if (location != 0) numFilters++;
    if (!Strings.equal(name, "")) numFilters++;

    QueryFragment[] memory fragments = new QueryFragment[](numFilters + 1);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsMerchantCompID), "");

    uint256 filterCount;
    if (location != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, LocationCompID),
        abi.encode(location)
      );
    }
    if (!Strings.equal(name, "")) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, NameCompID),
        abi.encode(name)
      );
    }
    return LibQuery.query(fragments);
  }
}

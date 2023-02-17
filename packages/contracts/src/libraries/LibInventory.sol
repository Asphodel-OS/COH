// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdHolderComponent, ID as IdHolderCompID } from "components/IdHolderComponent.sol";
import { IndexItemComponent, ID as IndexItemCompID } from "components/IndexItemComponent.sol";
import { IsInventoryComponent, ID as IsInventoryCompID } from "components/IsInventoryComponent.sol";
import { BalanceComponent, ID as BalanceCompID } from "components/BalanceComponent.sol";

library LibInventory {
  /////////////////
  // INTERACTIONS

  // create an inventory entity for an entity
  function create(
    IWorld world,
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsInventoryComponent(getAddressById(components, IsInventoryCompID)).set(id);
    IdHolderComponent(getAddressById(components, IdHolderCompID)).set(id, holderID);
    IndexItemComponent(getAddressById(components, IndexItemCompID)).set(id, itemIndex);
    BalanceComponent(getAddressById(components, BalanceCompID)).set(id, 0);
    return id;
  }

  // transfers the specified inventory amt from=>to entity
  function transfer(
    IComponents components,
    uint256 fromID,
    uint256 toID,
    uint256 amt
  ) internal {
    dec(components, fromID, amt);
    inc(components, toID, amt);
  }

  // increases an inventory balance by the specified amount
  function inc(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    bal += amt;
    _set(components, id, bal);
    return bal;
  }

  // decreases an inventory balance by the specified amount
  function dec(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    require(bal >= amt, "Inventory: insufficient balance");
    bal -= amt;
    _set(components, id, bal);
    return bal;
  }

  // set the balance of an existing inventory entity
  function _set(
    IComponents components,
    uint256 id,
    uint256 amt
  ) internal {
    BalanceComponent(getAddressById(components, BalanceCompID)).set(id, amt);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getBalance(IComponents components, uint256 id) internal view returns (uint256) {
    return BalanceComponent(getAddressById(components, BalanceCompID)).getValue(id);
  }

  function getItemIndex(IComponents components, uint256 id) internal view returns (uint256) {
    return IndexItemComponent(getAddressById(components, IndexItemCompID)).getValue(id);
  }

  function getHolder(IComponents components, uint256 id) internal view returns (uint256) {
    return IdHolderComponent(getAddressById(components, IdHolderCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get the id of an inventory entity based on owner ID and item index
  function get(
    IComponents components,
    uint256 holderID,
    uint256 itemIndex
  ) internal view returns (uint256 result) {
    QueryFragment[] memory fragments = new QueryFragment[](3);
    fragments[0] = QueryFragment(
      QueryType.Has,
      getComponentById(components, IsInventoryCompID),
      ""
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdHolderCompID),
      abi.encode(holderID)
    );
    fragments[2] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IndexItemCompID),
      abi.encode(itemIndex)
    );

    uint256[] memory results = LibQuery.query(fragments);
    if (results.length != 0) {
      result = results[0];
    }
  }

  // gets all inventories associated with an entity
  function getAll(IComponents components, uint256 id) internal view returns (uint256[] memory) {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(
      QueryType.Has,
      getComponentById(components, IsInventoryCompID),
      ""
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdHolderCompID),
      abi.encode(id)
    );

    return LibQuery.query(fragments);
  }
}

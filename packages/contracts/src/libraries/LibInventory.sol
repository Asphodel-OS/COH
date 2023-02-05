// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdOwnerComponent, ID as IdOwnerComponentID } from "components/IdOwnerComponent.sol";
import { IndexItemComponent, ID as IndexItemComponentID } from "components/IndexItemComponent.sol";
import { IsInventoryComponent, ID as IsInventoryComponentID } from "components/IsInventoryComponent.sol";
import { BalanceComponent, ID as BalanceComponentID } from "components/BalanceComponent.sol";

library LibInventory {
  /*********************
   *     INVENTORY
   *********************/

  // create an inventory entity for an entity
  function create(
    IWorld world,
    IUint256Component components,
    uint256 entityID,
    uint256 itemIndex
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsInventoryComponent(getAddressById(components, IsInventoryComponentID)).set(id);
    IdOwnerComponent(getAddressById(components, IdOwnerComponentID)).set(id, entityID);
    IndexItemComponent(getAddressById(components, IndexItemComponentID)).set(id, itemIndex);
    BalanceComponent(getAddressById(components, BalanceComponentID)).set(id, 0);
    return id;
  }

  // get the id of an inventory entity based on owner ID and item index
  function get(
    IUint256Component components,
    uint256 entityID,
    uint256 itemIndex
  ) internal view returns (uint256) {
    QueryFragment[] memory fragments = new QueryFragment[](3);
    fragments[0] = QueryFragment(
      QueryType.Has,
      getComponentById(components, IsInventoryComponentID),
      ""
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdOwnerComponentID),
      abi.encode(entityID)
    );
    fragments[2] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IndexItemComponentID),
      abi.encode(itemIndex)
    );

    uint256[] memory inventoryIDs = LibQuery.query(fragments);
    if (inventoryIDs.length == 0) {
      return 0;
    }

    return inventoryIDs[0];
  }

  // gets all inventories associated with an entity
  function getAll(IUint256Component components, uint256 id)
    internal
    view
    returns (uint256[] memory)
  {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(
      QueryType.Has,
      getComponentById(components, IsInventoryComponentID),
      ""
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdOwnerComponentID),
      abi.encode(id)
    );

    return LibQuery.query(fragments);
  }

  /*********************
   *     BALANCES
   *********************/

  // adds an amount to the balance of an existing item inventory entity
  function addBalance(
    IUint256Component components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    bal += amt;
    setBalance(components, id, bal);
    return bal;
  }

  // subtracts an amount from the balance of an existing item inventory entity
  function subBalance(
    IUint256Component components,
    uint256 id,
    uint256 amt
  ) internal returns (uint256) {
    uint256 bal = getBalance(components, id);
    require(bal >= amt, "Inventory: insufficient balance");
    bal -= amt;
    setBalance(components, id, bal);
    return bal;
  }

  // set the balance of an existing inventory entity
  function setBalance(
    IUint256Component components,
    uint256 id,
    uint256 amt
  ) internal {
    BalanceComponent(getAddressById(components, BalanceComponentID)).set(id, amt);
  }

  // set the balance of an inventory entity
  function getBalance(IUint256Component components, uint256 id) internal view returns (uint256) {
    return BalanceComponent(getAddressById(components, BalanceComponentID)).getValue(id);
  }

  // set the item type of an inventory entity
  function getItemType(IUint256Component components, uint256 id) internal view returns (uint256) {
    return IndexItemComponent(getAddressById(components, IndexItemComponentID)).getValue(id);
  }
}

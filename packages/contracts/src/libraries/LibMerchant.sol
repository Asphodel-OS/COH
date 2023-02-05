// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IsMerchantComponent, ID as IsMerchantComponentID } from "components/IsMerchantComponent.sol";
import { IdMerchantComponent, ID as IdMerchantComponentID } from "components/IdMerchantComponent.sol";
import { NameComponent, ID as NameComponentID } from "components/NameComponent.sol";
import { LocationComponent, ID as LocationComponentID } from "components/LocationComponent.sol";
import { PriceBuyComponent, ID as PriceBuyComponentID } from "components/PriceBuyComponent.sol";
import { PriceSellComponent, ID as PriceSellComponentID } from "components/PriceSellComponent.sol";
import { IndexItemComponent, ID as IndexItemComponentID } from "components/IndexItemComponent.sol";
import "libraries/LibCoin.sol";
import "libraries/LibInventory.sol";

/*
 * LibMerchant handles all operations interacting with Merchants
 */
library LibMerchant {
  /************************
   *       Merchant
   ************************/

  // For now, this function does nothing special. It creates an entity with a name and room.
  function createMerchant(
    IWorld world,
    IUint256Component components,
    uint256 location,
    string memory name
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsMerchantComponent(getAddressById(components, IsMerchantComponentID)).set(id);
    NameComponent(getAddressById(components, NameComponentID)).set(id, name);
    LocationComponent(getAddressById(components, LocationComponentID)).set(id, location);
    return id;
  }

  /************************
   *       Listings
   ************************/

  // returns an existing listing ID or creates one with the specified parameters
  function getOrCreateListing(
    IWorld world,
    IUint256Component components,
    uint256 merchantID,
    uint256 itemIndex,
    uint256 buyPrice,
    uint256 sellPrice
  ) internal returns (uint256) {
    uint256 listingID = getListing(components, merchantID, itemIndex);
    if (listingID == 0) {
      listingID = createListing(world, components, merchantID, itemIndex, buyPrice, sellPrice);
    }
    return listingID;
  }

  // creates a merchant listing with the specified parameters
  function createListing(
    IWorld world,
    IUint256Component components,
    uint256 merchantID,
    uint256 itemIndex,
    uint256 buyPrice,
    uint256 sellPrice
  ) internal returns (uint256) {
    uint256 listingID = world.getUniqueEntityId();
    IdMerchantComponent(getAddressById(components, IndexItemComponentID)).set(
      listingID,
      merchantID
    );
    IndexItemComponent(getAddressById(components, IndexItemComponentID)).set(listingID, itemIndex);

    // set buy and sell prices if valid
    if (buyPrice != 0) {
      PriceBuyComponent(getAddressById(components, PriceBuyComponentID)).set(listingID, buyPrice);
    }
    if (sellPrice != 0) {
      PriceSellComponent(getAddressById(components, PriceSellComponentID)).set(
        listingID,
        sellPrice
      );
    }

    return listingID;
  }

  // processes a buy for amt of item from a listing to a character
  function buyFromListing(
    IUint256Component components,
    uint256 charID,
    uint256 listingID,
    uint256 amt
  ) internal returns (bool) {
    uint256 itemIndex = IndexItemComponent(getAddressById(components, IndexItemComponentID))
      .getValue(listingID);
    uint256 price = PriceBuyComponent(getAddressById(components, PriceBuyComponentID)).getValue(
      listingID
    );
    if (price == 0) {
      return false;
    }

    uint256 inventoryID = LibInventory.get(components, charID, itemIndex);
    LibInventory.incBalance(components, inventoryID, amt);
    LibCoin.decBalance(components, charID, amt * price);
    return true;
  }

  // processes a sell for amt of item from a character to a listing
  function sellToListing(
    IUint256Component components,
    uint256 charID,
    uint256 listingID,
    uint256 amt
  ) internal returns (bool) {
    uint256 itemIndex = IndexItemComponent(getAddressById(components, IndexItemComponentID))
      .getValue(listingID);
    uint256 price = PriceSellComponent(getAddressById(components, PriceSellComponentID)).getValue(
      listingID
    );
    if (price == 0) {
      return false;
    }

    uint256 inventoryID = LibInventory.get(components, charID, itemIndex);
    LibInventory.decBalance(components, inventoryID, amt);
    LibCoin.incBalance(components, charID, amt * price);
    return true;
  }

  // gets all listings from a merchant
  function getListings(IUint256Component components, uint256 merchantID)
    internal
    view
    returns (uint256[] memory)
  {
    QueryFragment[] memory fragments = new QueryFragment[](1);
    fragments[0] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdMerchantComponentID),
      abi.encode(merchantID)
    );

    return LibQuery.query(fragments);
  }

  // gets an item listing from a merchant
  function getListing(
    IUint256Component components,
    uint256 merchantID,
    uint256 itemIndex
  ) internal view returns (uint256) {
    QueryFragment[] memory fragments = new QueryFragment[](2);
    fragments[0] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IdMerchantComponentID),
      abi.encode(merchantID)
    );
    fragments[1] = QueryFragment(
      QueryType.HasValue,
      getComponentById(components, IndexItemComponentID),
      abi.encode(itemIndex)
    );

    uint256[] memory results = LibQuery.query(fragments);
    if (results.length == 0) {
      return 0;
    }
    return results[0];
  }
}

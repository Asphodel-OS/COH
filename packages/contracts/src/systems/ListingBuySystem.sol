// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibListing } from "libraries/LibListing.sol";
import { LibInventory } from "libraries/LibInventory.sol";

uint256 constant ID = uint256(keccak256("system.ListingBuy"));

// ListingBuySystem allows a operator to buy an item listed with a merchant
contract ListingBuySystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 listingID, uint256 amt) = abi.decode(arguments, (uint256, uint256));
    uint256 operatorID = uint256(uint160(msg.sender));

    require(LibListing.canTransact(components, listingID, operatorID), "Merchant: must be in room");

    // create an inventory for the operator if one doesn't exist
    uint256 itemIndex = LibListing.getItemIndex(components, listingID);
    if (LibInventory.get(components, operatorID, itemIndex) == 0) {
      LibInventory.create(world, components, operatorID, itemIndex);
    }

    LibListing.buyFrom(components, listingID, operatorID, amt);
    return "";
  }

  function executeTyped(uint256 listingID, uint256 amt) public returns (bytes memory) {
    return execute(abi.encode(listingID, amt));
  }
}

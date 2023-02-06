// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibCharacter } from "libraries/LibCharacter.sol";
import { LibMerchant } from "libraries/LibMerchant.sol";
import { LibRoom } from "libraries/LibRoom.sol";

uint256 constant ID = uint256(keccak256("system.ListingBuy"));

// ListingBuySystem allows a character to buy an item listed with a merchant
contract ListingBuySystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public returns (bytes memory) {
    (uint256 charID, uint256 listingID, uint256 amt) = abi.decode(
      arguments,
      (uint256, uint256, uint256)
    );
    require(LibCharacter.getOperator(components, charID) == msg.sender, "Character: not urs");
    require(
      LibMerchant.canTransactWithListing(components, charID, listingID),
      "Merchant: character must be in room"
    );

    LibMerchant.buyFromListing(world, components, charID, listingID, amt);
    return "";
  }

  function executeTyped(
    uint256 charID,
    uint256 listingID,
    uint256 amt
  ) public returns (bytes memory) {
    return execute(abi.encode(charID, listingID, amt));
  }
}

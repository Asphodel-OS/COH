import { BigNumberish } from "ethers";
import { createPlayerAPI } from "./player";

export function createAdminAPI(systems: any) {
  function init() {
    createRoom("room0", 0, [1]);
    createRoom("room1", 1, [2, 3]);
    createRoom("room2", 2, [1]);
    createRoom("room3", 3, [1]);

    createNode("room2 node", 2);
    createNode("room3 node", 3);

    createMerchant("room1 merchant", 1);
    createMerchant("room2 merchant", 2);

    // required to init erc721 registy system, very temporary
    systems["system.ERC721.pet"].init();

    createPlayerAPI(systems).ERC721.mint('0x7681A73aed06bfb648a5818B978fb018019F6900');

    // TODO: can only set listings after know merchant IDs, how to address this?
  }

  // @dev creates a merchant with the name at the specified room
  // @param location  room ID
  // @param name      name of the merchant
  // @return uint     (promise) entity ID of the merchant
  function createMerchant(name: string, location: number) {
    return systems["system.MerchantCreate"].executeTyped(name, location);
  }

  // @dev creates an emission node at the specified location
  // @param name      name of the deposit (exposed in mining modal)
  // @param location  index of the room location
  // @return uint     entity ID of the deposit
  function createNode(
    name: string,
    location: number,
  ) {
    return systems["system.NodeCreate"].executeTyped(name, location);
  }

  // @dev creates a room with name, location and exits. cannot overwrite room at location
  function createRoom(name: string, location: number, exits: number[]) {
    return systems["system.RoomCreate"].executeTyped(name, location, exits);
  }

  // @dev allows a character to sell an item through a merchant listing entity
  // @param merchantID  entity ID of merchant
  // @param itemIndex   index of item to list
  // @param buyPrice    sell price of item listing (pass in 0 to leave blank)
  // @param sellPrice   buy price of item listing (pass in 0 to leave blank)
  // @return uint       (promise) entity ID of the listing
  function setListing(
    merchantID: BigNumberish,
    itemIndex: number,
    buyPrice: number,
    sellPrice: number
  ) {
    return systems["system.ListingSet"].executeTyped(merchantID, itemIndex, buyPrice, sellPrice);
  }

  return {
    init,
    createMerchant,
    createNode,
    createRoom,
    setListing,
  };
}

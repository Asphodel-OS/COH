import { BigNumberish } from "ethers";

export function createAdminAPI(systems: any) {
  function init() {

  }

  // @dev creates an emission node at the specified location
  // @param name      name of the deposit (exposed in mining modal)
  // @param location  index of the room location
  // @return uint     entity ID of the deposit
  function createNode(
    name: string,
    location: BigNumberish,
  ) {
    return systems["system.NodeCreate"].executeTyped(name, location);
  }

  // @dev creates a merchant with the name at the specified room
  // @param location  room ID
  // @param name      name of the merchant
  // @return uint     (promise) entity ID of the merchant
  function createMerchant(location: BigNumberish, name: string) {
    return systems["system.MerchantCreate"].executeTyped(location, name);
  }

  // @dev allows a character to sell an item through a merchant listing entity
  // @param merchantID  entity ID of merchant
  // @param itemIndex   index of item to list
  // @param buyPrice    sell price of item listing (pass in 0 to leave blank)
  // @param sellPrice   buy price of item listing (pass in 0 to leave blank)
  // @return uint       (promise) entity ID of the listing
  function setListing(
    merchantID: BigNumberish,
    itemIndex: BigNumberish,
    buyPrice: number,
    sellPrice: number
  ) {
    return systems["system.ListingSet"].executeTyped(merchantID, itemIndex, buyPrice, sellPrice);
  }

  return {
    init,
    createMerchant,
    createNode,
    setListing,
  };
}

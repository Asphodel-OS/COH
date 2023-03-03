import { BigNumberish } from "ethers";
import { createPlayerAPI } from "./player";

export function createAdminAPI(systems: any) {
  function init() {
    createRoom("deadzone", 0, [1]); // in case we need this
    createRoom("Quiet Forest", 1, [2]);
    createRoom("Vending Machine", 2, [1, 3]);
    createRoom("Corridor", 3, [2, 4]);
    createRoom("Kami Shop", 4, [3]);

    createNode("Eerie Willow", 1);
    createNode("Trash Compactor", 2);
    createNode("Pristine Couch", 3);
    createNode("Cash Register", 4);

    createMerchant("ugajin", 4);
    setListing(4, 1, 10, 5); // merchant, item index, buy price, sell price
    setListing(4, 2, 30, 15);
    setListing(4, 3, 50, 25);
    setListing(4, 4, 100, 50);

    // init general, mostly temp
    systems["system._Init"].executeTyped();
    systems["system.ERC721.metadata"]._setRevealed("123", "https://kamigotchi.nyc3.cdn.digitaloceanspaces.com/images%2F");
    // systems["system.ERC721.metadata"]._setMaxElements(['9', '1', '7', '8', '1']); 
    systems["system.ERC721.metadata"]._setMaxElements(['2', '1', '2', '2', '1']); 
    // systems["system.ERC721.metadata"]._setMaxElements(['1', '1', '1', '1', '1']); 
    
    createPlayerAPI(systems).ERC721.mint('0x7681A73aed06bfb648a5818B978fb018019F6900');

    // TODO: can only set listings after know merchant IDs, how to address this?
  }

  // @dev adds a modifier registry
  function addModReg(index: number, value: number, type: string, name: string) {
    return systems["system._AddModifier"].executeTyped(index, value, type, name);
  }

  // @dev creates a merchant with the name at the specified location
  // @param location  room ID
  // @param name      name of the merchant
  // @return uint     (promise) entity ID of the merchant
  function createMerchant(name: string, location: number) {
    return systems["system._MerchantCreate"].executeTyped(name, location);
  }

  // @dev creates an emission node at the specified location
  // @param name      name of the deposit (exposed in mining modal)
  // @param location  index of the room location
  // @return uint     entity ID of the deposit
  function createNode(name: string, location: number) {
    return systems["system._NodeCreate"].executeTyped(name, location);
  }

  // @dev creates a room with name, location and exits. cannot overwrite room at location
  function createRoom(name: string, location: number, exits: number[]) {
    return systems["system._RoomCreate"].executeTyped(name, location, exits);
  }

  // @dev sets the prices for the merchant at the specified location
  // @param location    location of the merchant
  // @param itemIndex   index of item to list
  // @param buyPrice    sell price of item listing (pass in 0 to leave blank)
  // @param sellPrice   buy price of item listing (pass in 0 to leave blank)
  // @return uint       (promise) entity ID of the listing
  function setListing(
    location: number,
    itemIndex: number,
    buyPrice: number,
    sellPrice: number
  ) {
    return systems["system._ListingSet"].executeTyped(location, itemIndex, buyPrice, sellPrice);
  }

  return {
    init,
    createMerchant,
    createNode,
    createRoom,
    setListing,
  };
}

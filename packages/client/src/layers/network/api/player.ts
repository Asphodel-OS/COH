import { BigNumberish } from "ethers";

export function createPlayerAPI(systems: any) {
  /*********************
   *     Listings
   *********************/
  // TODO: update these once listing logic is changed to utilize operator

  // @dev allows a character to buy an item through a merchant listing entity
  // @param characterID  entity ID of character
  // @param listingID    entity ID of listing
  // @param amt          amount to buy
  // @return bool        (promise) whether the transaction was successful
  function buyFromListing(
    characterID: BigNumberish,
    listingID: BigNumberish,
    amt: number
  ) {
    return systems["system.ListingBuy"].executeTyped(characterID, listingID, amt);
  }

  // @dev allows a character to sell an item through a merchant listing entity
  // @param characterID  entity ID of character
  // @param listingID    entity ID of listing
  // @param amt          amount to sell
  // @return bool        (promise) whether the transaction was successful
  function sellToListing(
    characterID: BigNumberish,
    listingID: BigNumberish,
    amt: number
  ) {
    return systems["system.ListingSell"].executeTyped(characterID, listingID, amt);
  }

  /*********************
   *    PRODUCTIONS 
   *********************/
  // TODO: update these once production logic is changed to utilize operator

  // @dev retrieves the amount due from a passive deposit production and resets the starting point
  function collectProduction(charID: BigNumberish, depositID: BigNumberish) {
    return systems["system.ProductionCollect"].executeTyped(charID, depositID);
  }

  // @dev starts a deposit production for a character. If none exists, it creates one.
  function startProduction(charID: BigNumberish, depositID: BigNumberish) {
    return systems["system.ProductionStart"].executeTyped(charID, depositID);
  }

  // @dev retrieves the amount due from a passive deposit production and stops it.
  function stopProduction(charID: BigNumberish, depositID: BigNumberish) {
    return systems["system.ProductionStop"].executeTyped(charID, depositID);
  }


  return {
    listing: {
      buy: buyFromListing,
      sell: sellToListing,
    },
    production: {
      collect: collectProduction,
      start: startProduction,
      stop: stopProduction,
    },
  };
}

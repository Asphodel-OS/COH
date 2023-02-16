import { BigNumberish } from "ethers";

export function createPlayerAPI(systems: any) {
  /*********************
   *    Pet ERC721
   *********************/
  // @dev 
  // @param address   address to mint to
  function mintPet(address: BigNumberish) {
    return systems["system.ERC721.pet"].mint(address);
  }

  // @dev
  // @param entityID   pet entity
  // @param name       name
  function namePet(petID: BigNumberish, name: string) {
    return systems["system.PetName"].executeTyped(petID, name);
  }

  /*********************
   *     OPERATOR
   *********************/
  // @dev moves the operator to another room from their current location
  // @param location  destination room location
  function moveOperator(location: number) {
    return systems["system.OperatorMove"].executeTyped(location);
  }

  // @dev   renames operator, ignoring previous name
  // @param entityID   pet entity
  // @param name       name
  function nameOperator(petID: BigNumberish, name: string) {
    return systems["system.OperatorName"].executeTyped(petID, name);
  }

  // @dev sets the operator of an Owner wallet. should be set by Owner wallet
  // @param operator  address of the operator wallet
  // @param name      name of the account
  function setOperator(operator: BigNumberish, name: string) {
    return systems["system.OperatorSet"].executeTyped(operator, name);
  }

  /*********************
   *     Listings
   *********************/

  // @dev allows a character to buy an item through a merchant listing entity
  // @param listingID    entity ID of listing
  // @param amt          amount to buy
  function buyFromListing(listingID: BigNumberish, amt: number) {
    return systems["system.ListingBuy"].executeTyped(listingID, amt);
  }

  // @dev allows a character to sell an item through a merchant listing entity
  // @param listingID    entity ID of listing
  // @param amt          amount to sell
  function sellToListing(listingID: BigNumberish, amt: number) {
    return systems["system.ListingSell"].executeTyped(listingID, amt);
  }

  /*********************
   *    PRODUCTIONS 
   *********************/

  // @dev retrieves the amount due from a passive deposit production and resets the starting point
  function collectProduction(depositID: BigNumberish) {
    return systems["system.ProductionCollect"].executeTyped(depositID);
  }

  // @dev starts a deposit production for a character. If none exists, it creates one.
  function startProduction(depositID: BigNumberish) {
    return systems["system.ProductionStart"].executeTyped(depositID);
  }

  // @dev retrieves the amount due from a passive deposit production and stops it.
  function stopProduction(depositID: BigNumberish) {
    return systems["system.ProductionStop"].executeTyped(depositID);
  }


  /*********************
   *       TRADE
   *********************/

  // @dev Updates Trade to ACCEPTED, removes IsRequest Component, creates ACTIVE Registers
  // @param tradeID   entityID of the trade log
  function acceptTrade(tradeID: BigNumberish) {
    return systems["system.TradeAccept"].executeTyped(tradeID);
  }

  // @dev creates an itemInventory entity, assigns to trade register and transfers the
  // item balance specified amount of the item from the operator to trade register
  // @param tradeID   entityID of the trade log
  // @param itemType  the id of the item being added, 0 for merit
  // @param amt       quantity of item being added
  function addToTrade(tradeID: BigNumberish, itemType: number, amt: number) {
    return systems["system.TradeAddTo"].executeTyped(tradeID, itemType, amt);
  }

  // @dev Updates Trade to CANCELED, updates both Registers ACTIVE->CANCELED
  // @param tradeID entityID of the trade log
  function cancelTrade(tradeID: BigNumberish) {
    return systems["system.TradeCancel"].executeTyped(tradeID);
  }

  // @dev Updates Trade ACCEPTED->?COMPLETE, updates operator's register ACTIVE->CONFIRMED
  // @param tradeID   entityID of the trade log
  function confirmTrade(tradeID: BigNumberish) {
    return systems["system.TradeConfirm"].executeTyped(tradeID);
  }

  // @dev Creates an INITIATED Trade between Operator and toID, with IsRequest Component
  // @param toID  entityID of the trade request receiver
  function initiateTrade(toID: BigNumberish) {
    return systems["system.TradeInitiate"].executeTyped(toID);
  }

  return {
    ERC721: {
      mint: mintPet,
      name: namePet
    },
    listing: {
      buy: buyFromListing,
      sell: sellToListing,
    },
    operator: {
      move: moveOperator,
      name: nameOperator,
      set: setOperator,
    },
    production: {
      collect: collectProduction,
      start: startProduction,
      stop: stopProduction,
    },
    trade: {
      accept: acceptTrade,
      addTo: addToTrade,
      cancel: cancelTrade,
      confirm: confirmTrade,
      initiate: initiateTrade,
    }
  };
}

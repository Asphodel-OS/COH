import { BigNumber } from "ethers";
import React, { useState, useEffect } from "react";
import { map, merge } from "rxjs";
import { EntityIndex, getComponentValue, Has, HasValue, NotValue, runQuery, } from "@latticexyz/recs";

import { registerUIComponent } from "../engine/store";

// merchant window with listings. assumes at most 1 merchant per room
export function registerMerchantWindow() {
  registerUIComponent(
    "MerchantWindow",

    // Grid Config
    {
      colStart: 0,
      colEnd: 0,
      rowStart: 0,
      rowEnd: 0,
    },

    // Requirement (Data Manangement)
    (layers) => {
      const {
        network: {
          world,
          api: { player },
          network,
          components: {
            PlayerAddress,
            OperatorID,
            Coin,
            IsListing,
            IsInventory,
            IsMerchant,
            ItemIndex,
            Location,
            MerchantID,
            Name,
            PriceBuy,
            PriceSell,
          },
          actions,
        },
      } = layers;

      // get a Merchant object by index
      const getMerchant = (index: EntityIndex) => {
        return {
          id: world.entities[index],
          index,
          name: getComponentValue(Name, index)?.value as string,
          location: getComponentValue(Location, index)?.value as number,
        }
      }

      // get a Listing object by index
      const getListing = (index: EntityIndex) => {
        return {
          id: world.entities[index],
          index,
          itemType: getComponentValue(ItemIndex, index)?.value as number,
          buyPrice: getComponentValue(PriceBuy, index)?.value as number,
          sellPrice: getComponentValue(PriceSell, index)?.value as number,
        }
      }

      return merge(OperatorID.update$, Location.update$).pipe(  // controlled character
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const location = getComponentValue(Location, operatorIndex)?.value as number;
          const merchantResults = runQuery([
            Has(IsMerchant),
            HasValue(Location, { value: location }),
          ]);

          // if we have a merchant retrieve its listings
          let listings: any = [];
          let merchant, merchantIndex;
          if (merchantResults.size != 0) {
            merchantIndex = Array.from(merchantResults)[0];
            merchant = getMerchant(merchantIndex);
            const listingIndices = Array.from(runQuery([
              Has(IsListing),
              HasValue(MerchantID, { value: merchant.id }),
            ]));

            let listing;
            for (let i = 0; i < listingIndices.length; i++) {
              listing = getListing(listingIndices[i]);
              listings.push(listing);
            }
          }


          return {
            world,
            actions,
            api: player,
            data: {
              operator: {
                id: world.entities[operatorIndex],
                index: operatorIndex,
                // inventory,
                coin: getComponentValue(Coin, operatorIndex)?.value as number,
              },
              merchant,
              listings,
            } as any,
          };
        })
      );
    },

    // Render
    ({ world, actions, api, data }) => {
      // hide this component if merchant.index == 0

      // Actions to support within trade window:
      // BuyFromListing
      // SellToListing
      return (<div></div>);
    }
  );
}
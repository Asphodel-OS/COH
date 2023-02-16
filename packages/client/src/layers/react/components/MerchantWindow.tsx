import React, { useState, useEffect } from "react";
import { map, merge } from "rxjs";
import styled, { keyframes } from 'styled-components';
import { EntityID, EntityIndex, Has, HasValue, getComponentValue, runQuery, } from "@latticexyz/recs";

import { registerUIComponent } from "../engine/store";
import pompom from '../../../public/img/pompom.png'
import gakki from '../../../public/img/gakki.png'
import ribbon from '../../../public/img/ribbon.png'
import gum from '../../../public/img/gum.png'

const ItemImages = new Map([
  [1, pompom],
  [2, gakki],
  [3, ribbon],
  [4, gum],
]);

const ItemNames = new Map([
  [1, "pompom"],
  [2, "gakki"],
  [3, "ribbon"],
  [4, "gum"],
]);

// merchant window with listings. assumes at most 1 merchant per room
export function registerMerchantWindow() {
  registerUIComponent(
    "MerchantWindow",

    // Grid Config
    {
      colStart: 20,
      colEnd: 60,
      rowStart: 20,
      rowEnd: 60,
    },

    // Requirement (Data Manangement)
    (layers) => {
      const {
        network: {
          world,
          api: { player },
          network,
          components: {
            Coin,
            IsListing,
            IsInventory,
            IsMerchant,
            IsOperator,
            ItemIndex,
            Location,
            MerchantID,
            Name,
            OperatorID,
            PlayerAddress,
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

      return merge(OperatorID.update$, Location.update$).pipe(
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const operatorID = world.entities[operatorIndex];

          // get player location and list of merchants in this room
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
            actions,
            api: player,
            data: {
              operator: {
                id: operatorID,
                // inventory, // we probably want this, filtered by the sellable items
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
    ({ actions, api, data }) => {
      // hide this component if merchant.index == 0

      ///////////////////
      // ACTIONS

      // buy from a listing
      const buy = (listing: any, amt: number) => {
        const actionID = `Buying ${amt} of ${listing.itemType} at ${Date.now()}` as EntityID; // itemType should be replaced with the item's name
        actions.add({
          id: actionID,
          components: {},
          // on: data.operator.index, // what's the appropriate value here?
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return api.listing.buy(listing.id, amt);
          },
        });
      };

      // sell to a listing
      const sell = (listing: any, amt: number) => {
        const actionID = `Selling ${amt} of ${listing.itemType} at ${Date.now()}` as EntityID; // itemType should be replaced with the item's name
        actions.add({
          id: actionID,
          components: {},
          // on: data.operator.index, // what's the appropriate value here?
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return api.listing.sell(listing.id, amt);
          },
        });
      };

      ///////////////////
      // DISPLAY

      // [listing: {id, index, itemType, buyPrice, sellPrice}]
      const listings = (slots: any) =>
        slots.map((listing: any) => (
          <li style={{ color: "black", fontSize: "16px" }} key={listing.itemType}>
            <img src={ItemImages.get(listing.itemType)} />
            <b>Name</b> {ItemNames.get(listing.itemType)}
            <b>Buy Price</b> {listing.buyPrice}
            <Button
              style={{ pointerEvents: "auto" }}
              onClick={() => buy(listing, 1)}
            >buy</Button>
            <b>Sell Price</b> {listing.sellPrice}
            <Button
              style={{ pointerEvents: "auto" }}
              onClick={() => sell(listing, 1)}
            >buy</Button>
          </li>
        ));

      const hideModal = () => {
        const elementId = window.document.getElementById("merchant");
        if (elementId) {
          elementId.style.display = "none";
        }
      };

      return (
        <div id="merchant">
          <button style={{ pointerEvents: "auto" }} onClick={hideModal}>X</button>
          <ul>{listings(data.listings)}</ul>
        </div>
      );
    }
  );
}


const Button = styled.button`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 18px;
  margin: 4px 2px;
  cursor: pointer;
  border-radius: 5px;
  justify-content: center;
  font-family: Pixel;
`;

import React, { useState, useEffect } from "react";
import { map, merge } from "rxjs";
import { BigNumber } from "ethers";
import { EntityIndex, Has, HasValue, NotValue, getComponentValue, runQuery, } from "@latticexyz/recs";

import { registerUIComponent } from "../engine/store";

export function registerRequestQueue() {
  registerUIComponent(
    "RequestQueue",

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
            IsOperator,
            IsRequest,
            IsTrade,
            OperatorID,
            PlayerAddress,
            RequesteeID,
            RequesterID,
            State
          },
          actions,
        },
      } = layers;

      // gets a Request object from an index
      const getRequest = (index: EntityIndex) => {
        return {
          id: world.entities[index],
          index,
          requester: getComponentValue(RequesterID, index)?.value as string,
        }
      }

      return merge(OperatorID.update$, RequesteeID.update$).pipe(
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const operatorID = world.entities[operatorIndex];

          // get all requests based on type
          let tradeRequests: any = [];
          const tradeResults = Array.from(runQuery([
            Has(IsRequest),
            Has(IsTrade),
            HasValue(RequesteeID, { value: world.entities[operatorIndex] }),
            NotValue(State, { value: "CANCELED" }),
          ]));
          for (let i = 0; i < tradeResults.length; i++) {
            tradeRequests.push(getRequest(tradeResults[i]));
          }

          return {
            world,
            actions,
            api: player,
            data: {
              operator: {
                id: operatorID,
                index: operatorIndex,
              },
              requests: {
                // guild: guildRequests,
                // party: partyRequests,
                trade: tradeRequests,
              },
            } as any,
          };
        })
      );
    },

    // Render
    ({ world, actions, api, data }) => {
      // Actions to support on each request:
      // accept trade
      // cancel trade
      return (<div></div>);
    }
  );
}
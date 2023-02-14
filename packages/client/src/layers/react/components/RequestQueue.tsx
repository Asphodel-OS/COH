import { BigNumber } from "ethers";
import React, { useState, useEffect } from "react";
import { map, merge } from "rxjs";
import { Has, HasValue, NotValue, runQuery, } from "@latticexyz/recs";

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
            State
          },
          actions,
        },
      } = layers;

      return merge(OperatorID.update$, RequesteeID.update$).pipe(  // controlled character
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const operatorID = world.entities[operatorIndex];

          // TODO: get more details
          // get all requests based on type
          const tradeRequestIndices = Array.from(runQuery([
            Has(IsRequest),
            Has(IsTrade),
            HasValue(RequesteeID, { value: world.entities[operatorIndex] }),
            NotValue(State, { value: "CANCELED" }),
          ]));

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
                trade: tradeRequestIndices,
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
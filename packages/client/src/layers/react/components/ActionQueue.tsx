import React from 'react';
import {
  getComponentEntities,
  getComponentValueStrict,
} from '@latticexyz/recs';
import { map } from 'rxjs';
import { ActionStateString, ActionState } from '@latticexyz/std-client';
import { registerUIComponent } from '../engine/store';

export function registerActionQueue() {
  registerUIComponent(
    'ActionQueue',
    {
      rowStart: 3,
      rowEnd: 30,
      colStart: 34,
      colEnd: 62,
    },
    (layers) => {
      const {
        network: {
          actions: { Action },
        },
      } = layers;

      return Action.update$.pipe(
        map(() => ({
          Action,
        }))
      );
    },
    ({ Action }) => {
      return (
        <div>
          <p>Actions:</p>
          {[...getComponentEntities(Action)].map((e) => {
            const actionData = getComponentValueStrict(Action, e);
            const state = ActionStateString[actionData.state as ActionState];
            return (
              <p key={`action${e}`}>
                {Action.world.entities[e]}: {state}
              </p>
            );
          })}
        </div>
      );
    }
  );
}

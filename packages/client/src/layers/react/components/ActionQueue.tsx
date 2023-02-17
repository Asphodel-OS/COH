import React from 'react';
import {
  getComponentEntities,
  getComponentValueStrict,
} from '@latticexyz/recs';
import { map } from 'rxjs';
import { ActionStateString, ActionState } from '@latticexyz/std-client';
import { registerUIComponent } from '../engine/store';
import styled from 'styled-components';

export function registerActionQueue() {
  registerUIComponent(
    'ActionQueue',
    {
      rowStart: 40,
      rowEnd: 70,
      colStart: 87,
      colEnd: 96,
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
        <ModalWrapper>
          <ModalContent>
          <Description>Actions:</Description>
          {[...getComponentEntities(Action)].map((e) => {
            const actionData = getComponentValueStrict(Action, e);
            const state = ActionStateString[actionData.state as ActionState];
            return (
              <Description key={`action${e}`}>
                {Action.world.entities[e]}: {state}
              </Description>
            );
          })}
          </ModalContent>
        </ModalWrapper>
      );
    }
  );
}

const ModalWrapper = styled.div`
  display: grid;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 100%;
`;

const ModalContent = styled.div`
  display: flex;
  flex-direction: column;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  padding: 20px;
  width: 99%;
  border-style: solid;
  border-width: 2px;
  border-color: black;
`;

const Description = styled.p`
  font-size: 14px;
  color: #333;
  text-align: left;
  padding: 2px;
  font-family: Pixel;
`;

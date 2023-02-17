import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import styled from 'styled-components';
import './font.css';
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav';
import { dataStore } from '../store/createStore';

export function registerUpButton() {
  registerUIComponent(
    'UpButton',
    {
      colStart: 83,
      colEnd: 88,
      rowStart: 82,
      rowEnd: 87,
    },
    (layers) => of(layers),
    (layers) => {
      const {
        network: {
          api: {
            player: {
              operator: { move },
            },
          },
          actions,
        },
      } = layers;

      const {
        roomExits: { up },
      } = dataStore();

      const moveUpside = () => {
        const clickFX = new Audio(clickSound);
        clickFX.play();

        const actionID = `Moving...` as EntityID;

        actions.add({
          id: actionID,
          components: {},
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return move(up);
          },
        });
      };

      return (
        <ModalWrapper
          id="up_button"
          style={{ display: up === 0 ? 'none' : 'block' }}
        >
          <ModalContent>
            <Button style={{ pointerEvents: 'auto' }} onClick={moveUpside}>
              ↑
            </Button>
          </ModalContent>
        </ModalWrapper>
      );
    }
  );
}

const ModalWrapper = styled.div`
  background-color: rgba(0, 0, 0, 0.5);
  display: block;
`;

const ModalContent = styled.div`
  display: grid;
  background-color: white;
  border-radius: 10px;
  width: 99%;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  padding: 8px;
`;

const Button = styled.button`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 5px;
  font-size: 29px;
  cursor: pointer;
  border-radius: 5px;
  font-family: Pixel;

  &:active {
    background-color: #c2c2c2;
  }
`;

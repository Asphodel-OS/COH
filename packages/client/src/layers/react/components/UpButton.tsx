import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';
import './font.css';
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav'

export function registerUpButton() {
  registerUIComponent(
    'UpButton',
    {
      colStart: 82,
      colEnd: 87,
      rowStart: 76,
      rowEnd: 88,
    },
    (layers) => of(layers),
    () => {
      const {
        network: {
          network,
          api: { player: { operator: { move } } },
          world,
          actions,
        },
      } = window.layers!;

      const showMyKami = () => {
        const clickFX = new Audio(clickSound)
        clickFX.play()

        const actionID = `Moving at ${Date.now()}` as EntityID;

        actions.add({
          id: actionID,
          components: {},
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return move(1);
          },
        });
      };

      return (
        <ModalWrapper id="up_button">
          <ModalContent>
            <Button style={{ pointerEvents: 'auto' }} onClick={showMyKami}>
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

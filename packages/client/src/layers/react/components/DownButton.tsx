import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';
import './font.css';
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav'

export function registerDownButton() {
  registerUIComponent(
    'DownButton',
    {
      colStart: 82,
      colEnd: 87,
      rowStart: 87,
      rowEnd: 99,
    },
    (layers) => of(layers),
    () => {
      const {
        objectData: { description },
      } = dataStore();

      const showMyKami = () => {
        const clickFX = new Audio(clickSound)
        clickFX.play()
        const modalId = window.document.getElementById('petlist_modal');
        if (modalId.style.display === 'block') modalId.style.display = 'none';
        else modalId.style.display = 'block';
      };

      return (
        <ModalWrapper id="down_button">
          <ModalContent>
            <Button style={{ pointerEvents: 'auto' }} onClick={showMyKami}>
              ↓
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

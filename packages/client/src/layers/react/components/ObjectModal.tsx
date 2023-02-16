import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';
import './font.css';

export function registerObjectModal() {
  registerUIComponent(
    'ObjectModal',
    {
      colStart: 3,
      colEnd: 87,
      rowStart: 65,
      rowEnd: 99,
    },
    (layers) => of(layers),
    () => {
      const hideModal = () => {
        const modalId = window.document.getElementById('object_modal');
        if (modalId) modalId.style.display = 'none';
      };

      const {
        objectData: { description },
      } = dataStore();

      return (
        <ModalWrapper id="object_modal">
          <ModalContent>
          <AlignRight>
          <TopButton style={{ pointerEvents: 'auto'}} onClick={hideModal}>
            X
          </TopButton>
          </AlignRight>
            <Description>{description}</Description>
            <div style={{textAlign: "right"}}>
            <Button style={{ pointerEvents: 'auto'}}>
              Shop
            </Button>
            </div>
          </ModalContent>
        </ModalWrapper>
      );
    }
  );
}

const fadeIn = keyframes`
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
`;

const ModalWrapper = styled.div`
  display: none;
  background-color: rgba(0, 0, 0, 0.5);
  justify-content: center;
  align-items: center;
  animation: ${fadeIn} 0.5s ease-in-out;
`;

const AlignRight = styled.div`
  text-align: right;
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

const Description = styled.p`
  font-size: 22px;
  color: #333;
  text-align: center;
  padding: 20px;
  font-family: Pixel;
`;

const TopButton = styled.button`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 5px;
  font-size: 14px;
  cursor: pointer;
  pointer-events: auto;
  border-radius: 5px;
  font-family: Pixel;
  width: 30px;
  &:active {
    background-color: #c2c2c2;
  }
`;

import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';

export function registerObjectModal() {
  registerUIComponent(
    'ObjectModal',
    {
      colStart: 35,
      colEnd: 65,
      rowStart: 27,
      rowEnd: 63,
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
            <Description>{description}</Description>
            <Button style={{ pointerEvents: 'auto' }} onClick={hideModal}>
              Close
            </Button>
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

const ModalContent = styled.div`
  display: flex;
  flex-direction: column;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  padding: 20px;
  width: 99%;
`;

const Button = styled.button`
  background-color: #333;
  border: none;
  color: white;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  cursor: pointer;
  border-radius: 5px;
  justify-content: center;
`;

const Description = styled.p`
  font-size: 18px;
  color: #333;
  text-align: center;
  padding: 20px;
`;

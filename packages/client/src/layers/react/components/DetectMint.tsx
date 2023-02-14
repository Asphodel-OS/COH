import React from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { BigNumber } from 'ethers';
import styled, { keyframes } from 'styled-components';

export function registerDetectMint() {
  registerUIComponent(
    'DetectMint',
    {
      colStart: 40,
      colEnd: 60,
      rowStart: 40,
      rowEnd: 60,
    },
    (layers) => of(layers),

    (layers) => {
      const {
        network: {
          components: { PetID },
          api: { player },
        },
      } = layers;

      const handleMinting = () => {
        player.ERC721.mint(
          BigNumber.from(localStorage.getItem('burnerWalletAddress'))
        );

        document.getElementById('detectMint')!.style.display = 'none';
        document.getElementById('minting')!.style.display = 'block';
      };

      return (
        <ModalWrapper id="detectMint">
          <ModalContent>
            <Description>You didin't mint</Description>
            <Button style={{ pointerEvents: 'auto' }} onClick={handleMinting}>
              Mint Character
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
  display: block;
  background-color: rgba(0, 0, 0, 0.5);
  justify-content: center;
  align-items: center;
  animation: ${fadeIn} 1.3s ease-in-out;
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

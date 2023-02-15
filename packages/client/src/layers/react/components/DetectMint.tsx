/* eslint-disable @typescript-eslint/no-non-null-assertion */
import React, { useEffect, useState } from 'react';
import { map } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import styled, { keyframes } from 'styled-components';
import { HasValue, runQuery } from '@latticexyz/recs';
import mintSound from '../../../public/sound/sound_effects/tami_mint_vending_sound.mp3'

export function registerDetectMint() {
  registerUIComponent(
    'DetectMint',
    {
      colStart: 40,
      colEnd: 60,
      rowStart: 40,
      rowEnd: 60,
    },
    (layers) => {
      const {
        network: {
          components: { PetIndex },
        },
      } = layers;

      return PetIndex.update$.pipe(
        map(() => {
          return {
            layers,
          };
        })
      );
    },

    ({ layers }) => {
      const {
        network: {
          components: { PlayerAddress },
          api: { player },
          network: { connectedAddress },
        },
      } = layers;

      const [isDivVisible, setIsDivVisible] = useState(false);
      const hasPlayerMinted = Array.from(
        runQuery([HasValue(PlayerAddress, { value: connectedAddress.get() })])
      )[0];

      const handleMinting = async () => {
        try {
          const mintFX = new Audio(mintSound)
          mintFX.play()
          
          await player.ERC721.mint(connectedAddress.get()!);

          document.getElementById('detectMint')!.style.display = 'none';
          document.getElementById('mint_process')!.style.display = 'block';
        } catch (e) {
          //
        }
      };

      useEffect(() => {
        if (hasPlayerMinted != undefined) return setIsDivVisible(false);
        return setIsDivVisible(true);
      }, [setIsDivVisible, hasPlayerMinted]);

      return (
        <ModalWrapper
          id="detectMint"
          style={{ display: isDivVisible ? 'block' : 'none' }}
        >
          <ModalContent>
            <Description>You haven't minted.</Description>
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

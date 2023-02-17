/* eslint-disable @typescript-eslint/no-non-null-assertion */
import React, { useEffect, useState } from 'react';
import { map, merge } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import styled, { keyframes } from 'styled-components';
import { EntityIndex, EntityID, HasValue, Has, runQuery, getComponentValue } from '@latticexyz/recs';
import { dataStore } from '../store/createStore';
import mintSound from '../../../public/sound/sound_effects/tami_mint_vending_sound.mp3'
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav'
import { BigNumber } from "ethers";

type TraitDetails = {
  Name: string,
  Type: string, 
  Value: string,
}

type Details = {
  nftID: string,
  petName: string,
  uri: string,
  traits: TraitDetails[],
}

export function registerPetDetails() {
  registerUIComponent(
    'PetDetails',
    {
      colStart: 40,
      colEnd: 100,
      rowStart: 40,
      rowEnd: 100,
    },
    (layers) => {
      const {
        network: {
          components: { 
            IsPet,
            PetTraits,
            Balance,
           },
        },
      } = layers;

      return merge(IsPet.update$, PetTraits.update$, Balance.update$).pipe(
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
          components: { 
            IsPet,
            MediaURI,
            PetIndex,
            PlayerAddress,
            PetTraits,
            PetEquipped,
            ModifierValue,
            ModifierType,
            Name,
            State,
           },
           world
        },
      } = layers;

      const {
        selectedPet: { description },
      } = dataStore();

      /////////////////
      // Get values
      const getPetIndex = (tokenID: string) => {
        return Array.from(runQuery([
          Has(IsPet),
          HasValue(PetIndex, { value: BigNumber.from(tokenID).toHexString() })
        ]))[0];
      }

      const getDetails = (index: EntityIndex) => {
        return {
          nftID: getComponentValue(PetIndex, index)?.value as string,
          petName: getComponentValue(Name, index)?.value as string,
          uri: getComponentValue(MediaURI, index)?.value as string,
          traits: getArrayDetails(PetTraits, index)?.value as TraitDetails[],
        }
      }

      const getArrayDetails = ( comp: any, index: EntityIndex ) => {
        const rawArr = getComponentValue(comp, index)?.value as string[];
        let result: Array<TraitDetails> = [];
        
        for (let i = 0; i < rawArr.length; i++) {
          const ind = world.entityToIndex.get(rawArr[i] as EntityID) as EntityIndex;
          const n = getComponentValue(Name, ind)?.value as string;
          const t = getComponentValue(ModifierType, ind)?.value as string;
          const v = getComponentValue(ModifierValue, ind)?.value as string;

          result.push({ Name: n, Type: t, Value: v});
        }

        return {
          value: result
        }
      }

      /////////////////
      // Display values
      
      const [dets, setDets] = useState<Details>();

      useEffect(() => {
        if (description && description != "0") {
          console.log(description);
          setDets(getDetails(getPetIndex(description)));
        }
      }, [description]);

      const hideModal = () => {
        const clickFX = new Audio(clickSound)
        clickFX.play()
        const modalId = window.document.getElementById('petdetails_modal');
        if (modalId) modalId.style.display = 'none';
      };


      return (
        <ModalWrapper id="petdetails_modal">
          <ModalContent>
            <TopButton onClick={hideModal}>
              X
            </TopButton>
            <Description>Kamigotchi { dets?.petName } </Description>

            <Button style={{ pointerEvents: 'auto' }}>
              Mint Kamigotchi { description }
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
  animation: ${fadeIn} 0.3s ease-in-out;
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
  justify-self: right;
`;
/* eslint-disable @typescript-eslint/no-non-null-assertion */
import React, { useEffect, useState } from 'react';
import { map, merge } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';
import { HasValue, Has, runQuery, EntityID, EntityIndex, getComponentValue } from '@latticexyz/recs';
import { waitForActionCompletion } from "@latticexyz/std-client";
import mintSound from '../../../public/sound/sound_effects/tami_mint_vending_sound.mp3'
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav'
import { BigNumber, utils } from "ethers";

const SystemBalID = BigNumber.from(utils.id("system.ERC721.pet"))

export function registerPetMint() {
  registerUIComponent(
    'PetMint',
    {
      colStart: 40,
      colEnd: 60,
      rowStart: 40,
      rowEnd: 60,
    },
    (layers) => {
      const {
        network: {
          components: { IsPet, Balance },
          world,
        },
      } = layers;

      const getNextToken = () => {
        const id = world.entityToIndex.get(SystemBalID.toHexString() as EntityID);
        return getComponentValue(Balance, id as EntityIndex)?.value as number;
      }

      return merge(IsPet.update$, Balance.update$).pipe(
        map(() => {
          const nextToken = getNextToken();
          return {
            layers,
            nextToken,
          };
        })
      );
    },

    ({ layers, nextToken }) => {
      const {
        network: {
          components: { 
            OwnerID,
            IsPet,
            Balance
           },
          api: { player },
          network: { connectedAddress },
          actions,
          world,
        },
      } = layers;

      const mintTx = (address: string) => {
        const actionID = `Minting Pet at ${Date.now()}` as EntityID; // Date.now to have the actions ordered in the component browser
        actions.add({
          id: actionID,
          components: {},
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return player.ERC721.mint(
              address
            );
          },
        });
        return actionID;
      };

      const handleMinting = async () => {
        try {
          const mintFX = new Audio(mintSound)
          mintFX.play()
          
          const actionID = mintTx(connectedAddress.get()!);
          await waitForActionCompletion(
            actions.Action,
            world.entityToIndex.get(actionID) as EntityIndex
          );

          document.getElementById('petmint_modal')!.style.display = 'none';
          const nextId = document.getElementById('petdetails_modal');
          if (nextId && nextToken) {
            nextId.style.display = 'block';
            const description = BigNumber.from(nextToken).add("1").toHexString();
            // console.log(description);
            dataStore.setState({ objectData: { description } });
          }
        } catch (e) {
          //
        }
      };

      const hideModal = () => {
        const clickFX = new Audio(clickSound)
        clickFX.play()
        const modalId = window.document.getElementById('petmint_modal');
        if (modalId) modalId.style.display = 'none';
      };

      return (
        <ModalWrapper id="petmint_modal">
          <ModalContent>
            <TopButton onClick={hideModal}>
              X
            </TopButton>
            <Description>Mint a Kami</Description>
            <Button style={{ pointerEvents: 'auto' }} onClick={handleMinting}>
              Mint Kamigotchi
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
  display: grid;
  background-color: white;
  border-radius: 10px;
  padding: 8px;
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
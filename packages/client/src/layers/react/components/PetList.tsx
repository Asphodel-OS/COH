import React from 'react';
import { map, merge } from 'rxjs';
import styled, { keyframes } from 'styled-components';
import { EntityID, EntityIndex, Has, HasValue, NotValue, getComponentValue, runQuery } from "@latticexyz/recs";

import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import './font.css';

export function registerPetList() {
  registerUIComponent(
    'PetList',
    {
      colStart: 3,
      colEnd: 33,
      rowStart: 5,
      rowEnd: 35,
    },

    // Requirement (Data Manangement)
    (layers) => {
      const {
        network: {
          world,
          api: { player },
          network,
          components: {
            IsOperator,
            IsPet,
            MediaURI,
            OperatorID,
            OwnerID,
            PetIndex,
            PlayerAddress,
            State
          },
          actions,
        },
      } = layers;

      // gets a Pet object from an index
      // TODO(ja): support names, equips, stats and production details
      const getPet = (index: EntityIndex) => {
        const id = world.entities[index];
        return {
          id,
          index: getComponentValue(PetIndex, index)?.value as number,
          operator: { id: getComponentValue(OperatorID, index)?.value as EntityID },
          owner: { id: getComponentValue(OwnerID, index)?.value as EntityID },
          uri: getComponentValue(MediaURI, index)?.value as string,
        }
      }

      return merge(OperatorID.update$, OwnerID.update$).pipe(
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const operatorID = world.entities[operatorIndex];

          // get all indices of pets linked to this account and create object array
          let pets: any = [];
          const petResults = Array.from(runQuery([
            Has(IsPet),
            HasValue(OperatorID, { value: operatorID }),
          ]));
          for (let i = 0; i < petResults.length; i++) {
            pets.push(getPet(petResults[i]));
          }

          return {
            world,
            actions,
            api: player,
            data: {
              operator: {
                id: operatorID,
              },
              pets,
            } as any,
          };
        })
      );
    },

    // Render
    ({ world, actions, api, data }) => {
      const hideModal = () => {
        const modalId = window.document.getElementById('petlist_modal');
        if (modalId) modalId.style.display = 'none';
      };

      const {
        objectData: { description },
      } = dataStore();

      return (
        <ModalWrapper id="petlist_modal">
          <ModalContent>
            <TypeHeading>
              Your Kami
            </TypeHeading>
            <KamiBox>
              <KamiImage src="https://i.imgur.com/JkEsu5f.gif" />
              <KamiFacts>
                <Description> "I am in agony" </Description>
              </KamiFacts>
            </KamiBox>
            <KamiBox>
              <KamiImage src="https://i.imgur.com/Ut0wOld.gif" />
              <KamiFacts>
                <Description> "Uwu" </Description>
              </KamiFacts>
            </KamiBox>
            <div style={{ textAlign: "right" }}>
              <Button style={{ pointerEvents: 'auto' }} onClick={hideModal}>
                Close
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

const KamiBox = styled.div`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  text-decoration: none;
  display: grid;
  font-size: 18px;
  margin: 3px 2px;
  border-radius: 5px;
  font-family: Pixel;
`;

const KamiFacts = styled.div`
  background-color: #ffffff;
  color: black;
  font-size: 18px;
  margin: 0px;
  padding: 0px;
  grid-column: 2 / span 1000;
`;

const Description = styled.p`
  font-size: 16px;
  color: #333;
  text-align: left;
  padding: 20px;
  font-family: Pixel;
`;

const TypeHeading = styled.p`
  font-size: 20px;
  color: #333;
  text-align: left;
  padding: 20px;
  font-family: Pixel;
`;

const KamiImage = styled.img`
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
  height: 90px;
  margin: 0px;
  padding: 0px;
  grid-column: 1 / span 1;
`;

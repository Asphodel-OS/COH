import React from 'react';
import { map, merge } from 'rxjs';
import styled, { keyframes } from 'styled-components';
import { EntityIndex, Has, HasValue, NotValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { registerUIComponent } from '../engine/store';
import './font.css';

export function registerInventory() {
  registerUIComponent(
    'Inventory',
    {
      colStart: 34,
      colEnd: 64,
      rowStart: 5,
      rowEnd: 25,
    },
    // Requirement (Data Manangement)
    (layers) => {
      const {
        network: {
          world,
          api: { player },
          network,
          components: {
            Balance,
            Coin,
            HolderID,
            IsInventory,
            IsOperator,
            ItemIndex,
            OperatorID,
            PlayerAddress,
          },
          actions,
        },
      } = layers;

      // get a Inventory object by index
      const getInventory = (index: EntityIndex) => {
        const itemIndex = getComponentValue(ItemIndex, index)?.value as number;
        return {
          id: world.entities[index],
          index,
          item: {
            index: itemIndex, // this is the solecs index rather than the cached index
            // name: getComponentValue(Name, itemIndex)?.value as string,
            // description: ???, // are we intending to save this onchain or on FE?
          },
          balance: getComponentValue(Balance, index)?.value as number,
        }
      }

      return merge(OperatorID.update$, Balance.update$).pipe(
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const operatorID = world.entities[operatorIndex];

          // get the list of inventory indices for this account
          const inventoryResults = runQuery([
            Has(IsInventory),
            HasValue(HolderID, { value: operatorID }),
            NotValue(Balance, { value: 0 }),
          ]);

          // if we have inventories for the operator, list below
          let inventories: any = [];
          let inventory, inventoryIndex;
          if (inventoryResults.size != 0) {
            inventoryIndex = Array.from(inventoryResults)[0];
            inventory = getInventory(inventoryIndex);
            inventories.push(inventory);
          }

          return {
            world,
            actions,
            api: player,
            data: {
              operator: {
                id: operatorID,
                inventories,
                coin: getComponentValue(Coin, operatorIndex)?.value as number,
              },
            } as any,
          };
        })
      );
    },

    // RENDER
    ({ world, actions, api, data }) => {
      const hideModal = () => {
        const modalId = window.document.getElementById('inventory_modal');
        if (modalId) modalId.style.display = 'none';
      };

      return (
        <ModalWrapper id="inventory_modal">
          <ModalContent>
            <TypeHeading>Consumables</TypeHeading>
            <TypeHeading>Equipment</TypeHeading>
            <div style={{ textAlign: 'right' }}>
              <Button
                style={{ pointerEvents: 'auto'}}
                onClick={hideModal}
              >
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

const TypeHeading = styled.p`
  font-size: 20px;
  color: #333;
  text-align: left;
  padding: 20px;
  font-family: Pixel;
`;

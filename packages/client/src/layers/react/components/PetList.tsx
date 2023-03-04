import React, { useState, useEffect } from 'react';
import { map, merge } from 'rxjs';
import styled from 'styled-components';
import {
  EntityID,
  EntityIndex,
  Has,
  HasValue,
  getComponentValue,
  runQuery,
} from '@latticexyz/recs';
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import './font.css';
import pompom from '../../../public/img/pompom.png';
import gakki from '../../../public/img/gakki.png';
import ribbon from '../../../public/img/ribbon.png';
import gum from '../../../public/img/gum.png';
import clickSound from '../../../public/sound/sound_effects/mouseclick.wav';
import { ModalWrapper } from './styled/AnimModalWrapper';

const ItemImages = new Map([
  [1, pompom],
  [2, gakki],
  [3, ribbon],
  [4, gum],
]);

const ItemNames = new Map([
  [1, 'Pompom'],
  [2, 'Gakki'],
  [3, 'Ribbon'],
  [4, 'Gum'],
]);

export function registerPetList() {
  registerUIComponent(
    'PetList',
    {
      colStart: 3,
      colEnd: 33,
      rowStart: 2,
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
            Balance,
            Capacity,
            Charge,
            Coin,
            Bandwidth,
            HolderID,
            IsInventory,
            IsNode,
            IsOperator,
            IsProduction,
            IsPet,
            ItemIndex,
            LastActionTime,
            Location,
            MediaURI,
            Name,
            NodeID,
            OperatorID,
            OwnerID,
            PetID,
            PetIndex,
            PlayerAddress,
            State,
            StorageSize,
            StartTime,
          },
          actions,
        },
      } = layers;

      // aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      // aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      // aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      const hardCodeInventory = () => {
        return [
          {
            id: 1,
            itemIndex: 1,
            image: pompom,
            balance: 0,
          },
          {
            id: 2,
            itemIndex: 2,
            image: gakki,
            balance: 0,
          },
          {
            id: 3,
            itemIndex: 3,
            image: ribbon,
            balance: 0,
          },
          {
            id: 4,
            itemIndex: 4,
            image: gum,
            balance: 0,
          }
        ];
      }


      // get an Inventory object by index
      // TODO: get name and decription here once we have item registry support
      // NOTE: we need to do something about th FE/SC side overloading the term 'index'
      const getInventory = (index: EntityIndex) => {
        const itemIndex = getComponentValue(ItemIndex, index)?.value as number;
        return {
          id: world.entities[index],
          item: {
            index: itemIndex, // this is the solecs index rather than the cached index
            // name: getComponentValue(Name, itemIndex)?.value as string,
            // description: ???, // are we intending to save this onchain or on FE?
          },
          balance: getComponentValue(Balance, index)?.value as number,
        };
      };

      // this is about to be the jankiest bit inventory retrieval we will see..
      const getConsumables = (operatorIndex: EntityIndex) => {
        // pompom
        // gakki
        // ribbon
        // gum
      };

      // gets a Production object from an index
      const getProduction = (index: EntityIndex) => {
        return {
          id: world.entities[index],
          nodeId: getComponentValue(NodeID, index)?.value as string,
          state: getComponentValue(State, index)?.value as string,
          startTime: getComponentValue(StartTime, index)?.value as number,
        };
      };

      // gets a Pet object from an index
      // TODO(ja): support names, equips, stats and production details
      const getPet = (index: EntityIndex) => {
        const id = world.entities[index];

        // get the pet's prodcution object if it exists
        let production;
        const productionResults = Array.from(
          runQuery([Has(IsProduction), HasValue(PetID, { value: id })])
        );
        if (productionResults.length > 0) {
          production = getProduction(productionResults[0]);
        }

        return {
          id,
          index: getComponentValue(PetIndex, index)?.value as string,
          name: getComponentValue(Name, index)?.value as string,
          uri: getComponentValue(MediaURI, index)?.value as string,
          bandwidth: getComponentValue(Bandwidth, index)?.value as number,
          capacity: getComponentValue(Capacity, index)?.value as number,
          charge: getComponentValue(Charge, index)?.value as number,
          lastChargeTime: getComponentValue(LastActionTime, index)
            ?.value as number,
          storage: getComponentValue(StorageSize, index)?.value as number,
          production,
        };
      };

      return merge(
        OwnerID.update$,
        OperatorID.update$,
        Location.update$,
        Balance.update$,
        Coin.update$,
        State.update$,
        StartTime.update$
      ).pipe(
        map(() => {
          // get the operator entity of the controlling wallet
          const operatorEntityIndex = Array.from(
            runQuery([
              Has(IsOperator),
              HasValue(PlayerAddress, {
                value: network.connectedAddress.get(),
              }),
            ])
          )[0];
          const operatorID = world.entities[operatorEntityIndex];
          const bytes = getComponentValue(Coin, operatorEntityIndex)
            ?.value as number;

          // get the list of inventory indices for this account
          const inventoryResults = Array.from(runQuery([
            Has(IsInventory),
            HasValue(HolderID, { value: operatorID }),
          ]));
          let inventories: any = hardCodeInventory(); // the hardcoded slots we want for consumables

          // if we have inventories for the operator, generate a list of inventory objects
          let itemIndex;
          for (let i = 0; i < inventoryResults.length; i++) {
            // match indices to the existing consumables
            itemIndex = getComponentValue(ItemIndex, inventoryResults[i])?.value as number;
            for (let j = 0; j < inventories.length; j++) {
              if (inventories[j].itemIndex == itemIndex) {
                let balance = getComponentValue(Balance, inventoryResults[j])?.value as number;
                inventories[j].balance = balance ? balance * 1 : 0;
              }
            }
          }

          // get all indices of pets linked to this account and create object array
          let pets: any = [];
          const petResults = Array.from(
            runQuery([Has(IsPet), HasValue(OperatorID, { value: operatorID })])
          );
          for (let i = 0; i < petResults.length; i++) {
            pets.push(getPet(petResults[i]));
          }

          // get the node of the current room for starting productions
          let nodeID;
          let location = getComponentValue(Location, operatorEntityIndex)
            ?.value as number;
          const nodeResults = Array.from(
            runQuery([Has(IsNode), HasValue(Location, { value: location })])
          );
          if (nodeResults.length > 0) {
            nodeID = world.entities[nodeResults[0]];
          }

          return {
            actions,
            api: player,
            data: {
              operator: {
                id: operatorID,
                inventories,
                bytes,
              },
              pets,
              node: { id: nodeID },
            } as any,
          };
        })
      );
    },

    // Render
    ({ actions, api, data }) => {
      const { visibleDivs, setVisibleDivs } = dataStore();
      // console.log(data.pets);

      const [lastRefresh, setLastRefresh] = useState(Date.now());

      /////////////////
      // TICKING

      function refreshClock() {
        setLastRefresh(Date.now());
      }

      useEffect(() => {
        const timerId = setInterval(refreshClock, 1000);
        return function cleanup() {
          clearInterval(timerId);
        };
      }, []);

      /////////////////
      // INTERACTIONS

      // starts a production for the given pet on the node in the room
      const startProduction = (petID: EntityID) => {
        const actionID = `Starting Production at ${Date.now()}` as EntityID; // Date.now to have the actions ordered in the component browser
        actions.add({
          id: actionID,
          components: {},
          // on: data.????,
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return api.production.start(petID, data.node.id);
          },
        });
      };

      // stops a production
      const stopProduction = (productionID: EntityID) => {
        const actionID = `Stopping production at ${Date.now()}` as EntityID; // Date.now to have the actions ordered in the component browser
        actions.add({
          id: actionID,
          components: {},
          // on: data.????,
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return api.production.stop(productionID);
          },
        });
      };

      // collects on an existing production
      const reapProduction = (productionID: EntityID) => {
        const actionID = `Collecting production at ${Date.now()}` as EntityID; // Date.now to have the actions ordered in the component browser
        actions.add({
          id: actionID,
          components: {},
          // on: data.????,
          requirement: () => true,
          updates: () => [],
          execute: async () => {
            return api.production.collect(productionID);
          },
        });
      };

      const hideModal = () => {
        const clickFX = new Audio(clickSound);
        clickFX.play();

        setVisibleDivs({ ...visibleDivs, petList: !visibleDivs.petList });
      };

      /////////////////
      // DATA INTERPRETATION

      // NOTE(ja): the battery epoch is hardcoded right now but we should save this
      // on the world's global config
      const BATTERY_EPOCH = 1; // seconds

      // calculate energy (as % of total capacity) based on last charge and time passed since last charge
      const calcEnergy = (kami: any) => {
        let duration = (lastRefresh / 1000) - kami.lastChargeTime;
        let newCharge = Math.max(kami.charge - duration / BATTERY_EPOCH, 0);
        return (100 * newCharge / kami.capacity).toFixed(1);
        // return Math.round(100 * (1 - newCharge / kami.capacity)); // hunger calculation
      }

      // calculate the expected output from a pet production based on starttime and
      const calcOutput = (kami: any) => {
        let duration = 0,
          output = 0;
        if (kami.production && kami.production.state === 'ACTIVE') {
          duration = lastRefresh / 1000 - kami.production.startTime;
          output = Math.round(duration * kami.bandwidth);
          output = Math.min(output, kami.storage);
          output = Math.max(output, 0);
        }
        return output;
      };

      /////////////////
      // DISPLAY

      // Generate the list of Kami cards
      // TODO: grab uri from SC side
      const KamiCards = (kamis: any[]) => {
        return kamis.map((kami) => {
          return (
            <KamiBox key={kami.id}>
              <KamiImage src={kami.uri} />
              <KamiFacts>
                <KamiName>
                  <Description>{kami.name}</Description>
                </KamiName>
                <KamiDetails>
                  <Description>
                    Energy: {calcEnergy(kami)} %
                    <br />
                    Bandwidth: {kami.bandwidth * 1} / hr
                    <br />
                    Storage: {calcOutput(kami)} / {kami.storage * 1}
                    <br />
                  </Description>
                  {kami.production && kami.production.state === 'ACTIVE' ? (
                    <ThinButton
                      onClick={() => stopProduction(kami.production.id)}
                    >
                      Stop
                    </ThinButton>
                  ) : (
                    <ThinButton onClick={() => startProduction(kami.id)}>
                      Start
                    </ThinButton>
                  )}
                  {kami.production && kami.production.state === 'ACTIVE' ? (
                    <ThinButton
                      onClick={() => reapProduction(kami.production.id)}
                    >
                      Collect
                    </ThinButton>
                  ) : (
                    <ThinButton>Select Node</ThinButton>
                  )}
                </KamiDetails>
              </KamiFacts>
            </KamiBox>
          );
        });
      };

      // get the row of consumable items to display in the player inventory
      // NOTE: does not render until player inventories are populated
      const ConsumableCells = (inventories: any[]) => {
        return inventories.map((inv) => {
          return (
            <CellBordered style={{ gridColumn: `${inv.id}` }}>
              <CellGrid>
                <Icon src={inv.image} />
                <ItemNumber>{inv.balance ?? 0}</ItemNumber>
              </CellGrid>
            </CellBordered>
          );
        });
      };

      useEffect(() => {
        if (visibleDivs.petList == true)
          document.getElementById('petlist_modal')!.style.display = 'block';
      }, [visibleDivs.petList]);

      return (
        <ModalWrapper id="petlist_modal" isOpen={visibleDivs.petList}>
          <ModalContent>
            <TopGrid>
              <TopDescription>
                Bytes: {data.operator.bytes ? data.operator.bytes * 1 : '0'}
              </TopDescription>
              <TopButton onClick={hideModal}>X</TopButton>
            </TopGrid>
            <ConsumableGrid>
              {ConsumableCells(data.operator.inventories)}
            </ConsumableGrid>
            {KamiCards(data.pets)}
          </ModalContent >
        </ModalWrapper >
      );
    }
  );
}

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
  padding: 5px;
  display: inline-block;
  font-size: 14px;
  cursor: pointer;
  border-radius: 5px;
  font-family: Pixel;

  &:active {
    background - color: #c2c2c2;
}
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
  grid-column: 5;
  width: 30px;
  &:active {
    background - color: #c2c2c2;
}
  justify-self: right;
`;

const ThinButton = styled.button`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 5px;
  display: inline-block;
  font-size: 14px;
  cursor: pointer;
  pointer-events: auto;
  border-radius: 5px;
  font-family: Pixel;
  margin: 3px;
  &:active {
    background - color: #c2c2c2;
}
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
  margin: 4px 2px;
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
  display: grid;
`;

const KamiName = styled.div`
  grid-row: 1;
  border-style: solid;
  border-width: 0px 0px 2px 0px;
  border-color: black;
`;

const KamiDetails = styled.div`
  grid-row: 2 / 5;
`;

const Description = styled.p`
  font-size: 14px;
  color: #333;
  text-align: left;
  padding: 2px;
  font-family: Pixel;
`;

const TopDescription = styled.p`
  font-size: 14px;
  color: #333;
  text-align: left;
  font-family: Pixel;
  grid-column: 1;
  align-self: center;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  border-radius: 5px;
  padding: 5px;
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
  height: 110px;
  margin: 0px;
  padding: 0px;
  grid-column: 1 / span 1;
`;

const ConsumableGrid = styled.div`
  display: grid;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  border-radius: 5px;
  margin: 5px 2px 5px 2px;
`;

const TopGrid = styled.div`
  display: grid;
  margin: 2px;
`;

const CellGrid = styled.div`
  display: grid;
  border-style: solid;
  border-width: 0px;
  border-color: black;
`;

const CellBordered = styled.div`
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const CellBorderless = styled.div`
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const CellOne = styled.div`
  grid-column: 1;
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const CellTwo = styled.div`
  grid-column: 2;
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const CellThree = styled.div`
  grid-column: 3;
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const CellFour = styled.div`
  grid-column: 4;
`;

const Icon = styled.img`
  grid-column: 1;
  height: 40px;
  padding: 3px;
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
`;

const ItemNumber = styled.p`
  font-size: 14px;
  color: #333;
  font-family: Pixel;
  grid-column: 2;
  align-self: center;
`;

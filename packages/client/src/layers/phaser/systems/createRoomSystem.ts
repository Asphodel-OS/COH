/* eslint-disable @typescript-eslint/no-non-null-assertion */
import {
  defineSystem,
  Has,
  HasValue,
  runQuery,
} from '@latticexyz/recs';
import { NetworkLayer } from '../../network/types';
import { PhaserLayer, PhaserScene } from '../types';
import { getCurrentRoom } from '../utils';

export function createRoomSystem(network: NetworkLayer, phaser: PhaserLayer) {
  const {
    network: { connectedAddress },
    world,
    components: { Location, CharacterID },
  } = network;

  const {
    game: {
      scene: {
        keys: { Main },
      },
    },
  } = phaser;

  const myMain = Main as PhaserScene;

  const characterEntityNumber = Array.from(
    runQuery([HasValue(CharacterID, { value: connectedAddress.get() })])
  )[0];
  
  defineSystem(world, [Has(CharacterID), Has(Location)], async (update) => {
    if (characterEntityNumber == update.entity) {
      const currentRoom = getCurrentRoom(Location, update.entity);

      myMain.rooms![currentRoom].create(myMain);
    }
  });
}

/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { defineScene } from '@latticexyz/phaserx';
import { room001, room002, room003 } from '../rooms/';
import { PhaserScene } from '../types';

export function defineMainScene() {
  return {
    ['Main']: defineScene({
      key: 'Main',
      preload: (scene: PhaserScene) => {
        scene.rooms = [room001(), room002(), room003()];
      },
      create: (scene: PhaserScene) => {
        scene.rooms![0].create(scene);
      },
    }),
  };
}

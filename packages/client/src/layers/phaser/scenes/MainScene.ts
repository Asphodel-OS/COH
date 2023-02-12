/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { defineScene } from '@latticexyz/phaserx';
import { room001, room002, room003 } from '../rooms/';
import { PhaserScene, Room } from '../types';

export function defineMainScene() {
  return {
    ['Main']: defineScene({
      key: 'Main',
      preload: (scene: PhaserScene) => {
        scene.rooms = [room001(), room002(), room003()];

        scene.rooms.forEach((room: Room)=>{
          if(room.preload) room.preload!(scene);
        })
      },
      create: (scene: PhaserScene) => {
        scene.rooms![1].create(scene);
      },
    }),
  };
}

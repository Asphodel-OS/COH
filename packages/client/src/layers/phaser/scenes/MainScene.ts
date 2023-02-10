import { defineScene } from '@latticexyz/phaserx';
import { room001, room002, room003 } from '../rooms/';

export function defineMainScene() {
  return {
    ['Main']: defineScene({
      key: 'Main',
      preload: (scene: any) => {
        scene.rooms = [room001(), room002(), room003()];
      },
      create: (scene: any) => {
        scene.rooms[0].create(scene);
      },
    }),
  };
}

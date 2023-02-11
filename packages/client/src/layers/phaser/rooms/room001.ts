import { PhaserScene } from '../types';
import room001mage from '../../../public/assets/room1.png';

export function room001() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room001', room001mage);
    },
    create: (scene: PhaserScene) => {
      scene.add.image(900, 500, 'room001').setScale(10);
    },
  };
}

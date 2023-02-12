import { PhaserScene } from '../types';
import room001mage from '../../../public/assets/room1.png';
import { triggerObjectModal } from '../utils/trigerObjectModal';
import { resizePicture } from '../utils/resizePicture';

const scale = resizePicture();

export function room001() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room001', room001mage);
    },
    create: (scene: PhaserScene) => {
      scene.add.image(window.innerWidth / 2, window.innerHeight / 2, 'room001').setScale(scale * 8.3);

      const couch = scene.add.rectangle(450, 700, 200, 180, 0xff0000);

      triggerObjectModal(
        couch,
        'This is a couch used for testing the item description component. ');
    },
  };
}

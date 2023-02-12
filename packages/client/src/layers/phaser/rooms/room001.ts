import { PhaserScene } from '../types';
import room001mage from '../../../public/assets/room1.png';
import { triggerObjectModal } from '../utils/trigerObjectModal';

export function room001() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room001', room001mage);
    },
    create: (scene: PhaserScene) => {
      scene.add.image(900, 500, 'room001').setScale(10);

      const couch = scene.add.rectangle(500, 820, 200, 180);

      triggerObjectModal(
        couch,
        'This couch is the perfect addition to your protected area room. With its comfortable design, this couch offers a cozy and secure place to relax.'
      );
    },
  };
}

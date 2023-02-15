import { PhaserScene } from '../types';
import room002image from '../../../public/assets/room2.png';
import { resizePicture } from '../utils/resizePicture';
import { triggerObjectModal } from '../utils/triggerObjectModal';

const scale = resizePicture();

export function room002() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room002', room002image);
    },
    create: (scene: PhaserScene) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room002')
        .setScale(scale * 8.3);

      const vend = scene.add.rectangle(500, 820, 200, 180);
      const downArrow = scene.add.image(725, 560, 'arrow').setScale(1.75).setRotation(1.5714)

      const rightArrow = scene.add.image(1025, 360, 'arrow').setScale(1.75)


      triggerObjectModal(
        vend,
        'This couch is the perfect addition to your protected area room. With its comfortable design, this couch offers a cozy and secure place to relax.'
      );

    },
  };
}

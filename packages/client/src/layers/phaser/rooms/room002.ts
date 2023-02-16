import { PhaserScene } from '../types';
import room002image from '../../../public/assets/room2.png';
import { resizePicture } from '../utils/resizePicture';
import { triggerObjectModal } from '../utils/triggerObjectModal';
import { changeRoom } from '../utils/changeRoom';

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

      scene.interactiveObjects.push(
        triggerObjectModal(
          vend,
          'Quench your thirst with a refreshing soda, or indulge your sweet tooth with a chocolate bar. With just a few coins, our vending machine has got you covered. Grab a snack and keep the hunger at bay!'
        )
      );
    },
  };
}

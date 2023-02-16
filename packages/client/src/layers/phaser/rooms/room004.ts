import { PhaserScene } from '../types';
import { resizePicture } from '../utils/resizePicture';
import room004image from '../../../public/assets/room4.png';
import { changeRoom } from '../utils/changeRoom';

const scale = resizePicture();

export function room004() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room004', room004image);
    },
    create: (scene: PhaserScene) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room004')
        .setScale(scale * 8.3);

        const coordinates = getCouchCoordinates(scale);

        const girl = scene.add.rectangle(
          coordinates.x,
          coordinates.y,
          coordinates.width,
          coordinates.height
        );

        scene.interactiveObjects.push(
          triggerObjectModal(
            girl,
            'Please put the button that opens the shop menu in this modal.'
          )
        );
    },
  };
}

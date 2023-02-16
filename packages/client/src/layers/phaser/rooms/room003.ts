import { PhaserScene } from '../types';
import { resizePicture } from '../utils/resizePicture';
import room003image from '../../../public/assets/room3.png';
import { changeRoom } from '../utils/changeRoom';
import { getCouchCoordinates } from '../utils/coordinates';
import { triggerObjectModal } from '../utils/triggerObjectModal';

const scale = resizePicture();

export function room003() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room003', room003image);
    },
    create: (scene: PhaserScene) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room003')
        .setScale(scale * 8.3);

      const downArrow = scene.add
        .image(725, 560, 'arrow')
        .setScale(1.75)
        .setRotation(1.5714);

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

      scene.interactiveObjects.push(changeRoom(downArrow, 1));
    },
  };
}

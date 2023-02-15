import { PhaserScene } from '../types';
import room001mage from '../../../public/assets/room1.png';
import arrow from '../../../public/assets/arrow.png';
import { triggerObjectModal } from '../utils/triggerObjectModal';
import { triggerInventoryModal } from '../utils/triggerInventoryModal';
import { triggerPetListModal } from '../utils/triggerPetListModal';
import { resizePicture } from '../utils/resizePicture';
import { getCouchCoordinates } from '../utils/coordinates';

const scale = resizePicture();

export function room001() {
  return {
    preload: (scene: PhaserScene) => {
      scene.load.image('room001', room001mage);
      scene.load.image("arrow", arrow);
    },
    create: (scene: PhaserScene) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room001')
        .setScale(scale * 8.3);

      const coordinates = getCouchCoordinates(scale);

      const couch = scene.add.rectangle(
        coordinates.x,
        coordinates.y,
        coordinates.width,
        coordinates.height
      );

      const upArrow = scene.add.image(725, 360, 'arrow').setScale(1.75).setRotation(4.71239)

      const downArrow = scene.add.image(725, 560, 'arrow').setScale(1.75).setRotation(1.5714)

      triggerObjectModal(
        couch,
        'This is a couch used for testing the item description component.'
      );

    },
  };
}

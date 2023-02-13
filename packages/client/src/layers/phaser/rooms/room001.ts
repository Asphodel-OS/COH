import { PhaserScene } from '../types';
import room001mage from '../../../public/assets/room1.png';
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
        coordinates.height,
        0xff0000
      );

      const inventory = scene.add.rectangle(850, 400, 200, 180, 0xff0000);

      const petlist = scene.add.rectangle(350, 400, 200, 180, 0xff0000);

      triggerObjectModal(
        couch,
        'This is a couch used for testing the item description component.'
      );

      triggerInventoryModal(
        inventory
      );

      triggerPetListModal(
        petlist
      );


    },
  };
}

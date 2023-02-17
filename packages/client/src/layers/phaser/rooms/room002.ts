import { PhaserScene } from '../types';
import room002image from '../../../public/assets/room2.png';
import { resizePicture } from '../utils/resizePicture';
import { triggerPetMintModal } from '../utils/triggerPetMintModal';
import { getVendMachineCoordinates } from '../utils/coordinates';

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

      const vendMachineCoordinates = getVendMachineCoordinates(scale);

      const vend = scene.add.rectangle(
        vendMachineCoordinates.x,
        vendMachineCoordinates.y,
        vendMachineCoordinates.width,
        vendMachineCoordinates.height
      );

      scene.interactiveObjects.push(triggerPetMintModal(vend, 'Mint Pet'));
    },
  };
}

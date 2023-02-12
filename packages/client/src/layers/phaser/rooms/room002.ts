import room002image from '../../../public/assets/room2.png';
import { resizePicture } from '../utils/resizePicture';

const scale = resizePicture();

export function room002() {
  return {
    preload: (scene: any) => {
      scene.load.image('room002', room002image);
    },
    create: (scene: any) => {
      scene.add
        .image(window.innerWidth / 2, window.innerHeight / 2, 'room002')
        .setScale(scale * 8.3);
    },
  };
}

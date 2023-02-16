import { dataStore } from '../../react/store/createStore';
import dialogueSound from '../../../public/sound/sound_effects/speech3.mp3'

export const triggerObjectModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    const clickFX = new Audio(dialogueSound)
    clickFX.play()
    const objectId = document.getElementById('object_modal');
    if (objectId) {
      objectId.style.display = 'block';

      dataStore.setState({ objectData: { description } });
    }
  });
};

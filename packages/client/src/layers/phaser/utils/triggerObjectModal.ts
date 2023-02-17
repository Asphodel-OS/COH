import { dataStore } from '../../react/store/createStore';
import dialogueSound from '../../../public/sound/sound_effects/speech3.mp3';

export const triggerObjectModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    const clickFX = new Audio(dialogueSound);
    clickFX.play();

    const { visibleDivs } = dataStore.getState();
    
    dataStore.setState({ objectData: { description } });
    dataStore.setState({
      visibleDivs: { ...visibleDivs, objectModal: !visibleDivs.objectModal },
    });
    
  });
};

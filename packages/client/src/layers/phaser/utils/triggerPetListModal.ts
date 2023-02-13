import { dataStore } from '../../react/store/createStore';

export const triggerPetListModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    console.log("firing")
    const objectId = document.getElementById('petlist_modal');
    if (objectId) {
      objectId.style.display = 'block';

      dataStore.setState({ objectData: { description } });
    }
  });
};

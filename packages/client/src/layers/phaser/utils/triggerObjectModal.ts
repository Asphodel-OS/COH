import { dataStore } from '../../react/store/createStore';

export const triggerObjectModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    const objectId = document.getElementById('object_modal');
    if (objectId) {
      objectId.style.display = 'block';

      dataStore.setState({ objectData: { description } });
    }
  });
};

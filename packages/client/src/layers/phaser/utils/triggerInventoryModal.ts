import { dataStore } from '../../react/store/createStore';

export const triggerInventoryModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    console.log("firing")
    const objectId = document.getElementById('inventory_modal');
    if (objectId) {
      objectId.style.display = 'block';

      dataStore.setState({ objectData: { description } });
    }
  });
};

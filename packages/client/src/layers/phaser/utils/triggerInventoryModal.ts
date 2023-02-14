export const triggerInventoryModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    const objectId = document.getElementById('inventory_modal');
    if (objectId) {
      objectId.style.display = 'block';
    }
  });
};

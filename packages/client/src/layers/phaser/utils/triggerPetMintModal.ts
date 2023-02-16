export const triggerPetMintModal = (
  object: Phaser.GameObjects.GameObject,
  description: string
) => {
  return object.setInteractive().on('pointerdown', () => {
    const objectId = document.getElementById('petmint_modal');
    if (objectId) {
      objectId.style.display = 'block';
    }
  });
};

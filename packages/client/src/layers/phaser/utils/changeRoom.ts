/* eslint-disable @typescript-eslint/no-non-null-assertion */

export const changeRoom = (object: Phaser.GameObjects.Image, to: number) => {
  return object.setInteractive().on('pointerdown', () => {
    window.layers!.network.api.player.operator.move(to);
  });
};

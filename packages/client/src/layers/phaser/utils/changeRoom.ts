import { EntityID } from "@latticexyz/recs";

export const changeRoom = (object: Phaser.GameObjects.Image, to: number) => {
  const {
    network: {
      network,
      api: {
        player: { character },
      },
      world,
      actions,
      components: { EOAOwnedBy },
    },
  } = window.layers!;

  return object.setInteractive().on("pointerdown", () => {

    const actionID = `Moving at ${Date.now()}` as EntityID;

    actions.add({
      id: actionID,
      components: {},
      requirement: () => true,
      updates: () => [],
      execute: async () => {
        return window.layers!.network.api.player.operator.move(to);
      },
    });
  })
}

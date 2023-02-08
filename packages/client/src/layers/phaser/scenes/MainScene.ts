import { defineScene } from '@latticexyz/phaserx';

export function defineMainScene() {
  return {
    ['Main']: defineScene({
      key: 'Main',
      preload:() =>   {
         //
      },
      create:(scene) => {
        //
        scene.add.text(50, 150, "Welcome", {
          fontSize: "40px",
        });
      },
    }),
  };
}

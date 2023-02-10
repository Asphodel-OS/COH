export function room001() {
  return {
    create: (scene: any) => {
      scene.add.text(50, 150, 'Room 1', {
        fontSize: '40px',
        color: 'white',
      });
    },
  };
}

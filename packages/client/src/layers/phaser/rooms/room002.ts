export function room002() {
  return {
    create: (scene: any) => {
      scene.add.text(50, 150, 'Room 2', {
        fontSize: '40px',
        color: 'white',
      });
    },
  };
}

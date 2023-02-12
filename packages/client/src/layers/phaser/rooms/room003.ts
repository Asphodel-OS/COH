export function room003() {
  return {
    create: (scene: any) => {
      scene.add.text(50, 150, 'Room 3', {
        fontSize: '40px',
        color: 'white',
      });
    },
  };
}

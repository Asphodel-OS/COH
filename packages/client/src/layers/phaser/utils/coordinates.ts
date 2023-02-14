export const getCouchCoordinates = (scale: number) => {
  switch (scale) {
    case 0.85:
      return { x: 680, y: 740, width: 170, height: 170 };
    case 0.82:
      return { x: 490, y: 640, width: 150, height: 150 };
    case 0.75:
      return { x: 420, y: 610, width: 150, height: 150 };
    case 0.5:
      return { x: 170, y: 700, width: 170, height: 170 };
    case 0.33:
      return { x: 170, y: 600, width: 170, height: 170 };
    case 0.15:
      return { x: 170, y: 600, width: 150, height: 150 };
    default:
      return { x: 170, y: 900, width: 170, height: 170 };
  }
};

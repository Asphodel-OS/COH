export const getCouchCoordinates = (scale: number) => {
  switch (scale) {
    case 0.85:
      return { x: 580, y: 280, width: 230, height: 400 };
    case 0.82:
      return { x: 610, y: 240, width: 150, height: 350 };
    case 0.75:
      return { x: 420, y: 610, width: 150, height: 150 };
    case 0.5:
      return { x: 270, y: 700, width: 170, height: 170 };
    case 0.33:
      return { x: 170, y: 600, width: 170, height: 170 };
    case 0.15:
      return { x: 170, y: 600, width: 150, height: 150 };
    default:
      return { x: 170, y: 900, width: 170, height: 170 };
  }
};

export const getVendMachineCoordinates = (scale: number) => {
  switch (scale) {
    case 0.85:
      return { x: 500, y: 540, width: 200, height: 260 };
    case 0.82:
      return { x: 530, y: 500, width: 180, height: 220 };
    case 0.75:
      return { x: 500, y: 520, width: 200, height: 180 };
    case 0.5:
      return { x: 270, y: 700, width: 170, height: 170 };
    case 0.33:
      return { x: 170, y: 600, width: 170, height: 170 };
    case 0.15:
      return { x: 170, y: 600, width: 150, height: 150 };
    default:
      return { x: 500, y: 520, width: 200, height: 180 };
  }
}

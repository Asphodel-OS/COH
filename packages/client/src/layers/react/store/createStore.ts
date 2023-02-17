import create from 'zustand';

export interface DataObject {
  description: string;
}

export interface RoomExits {
  up: number;
  down: number;
}

export interface StoreState {
  objectData: DataObject;
  roomExits: RoomExits;
  selectedPet: DataObject;
}

interface StoreActions {
  setObjectData: (data: DataObject) => void;
  setRoomExits: (data: RoomExits) => void;
  setSelectedPet: (data: DataObject) => void;
}

export const dataStore = create<StoreState & StoreActions>((set) => {
  const initialState: StoreState = {
    objectData: { description: '' },
    roomExits: { up: 0, down: 0 },
    selectedPet: { description: '' },
  };

  return {
    ...initialState,
    setObjectData: (data: DataObject) =>
      set((state: StoreState) => ({ ...state, objectData: data })),
    setRoomExits: (data: RoomExits) =>
      set((state: StoreState) => ({ ...state, roomExits: data })),
    setSelectedPet: (data: DataObject) =>
      set((state: StoreState) => ({ ...state, objectData: data })),
  };
});

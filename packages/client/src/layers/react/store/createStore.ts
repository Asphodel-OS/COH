import create from 'zustand';

export interface DataObject {
  description: string;
}

export interface StoreState {
  objectData: DataObject;
}

interface StoreActions {
  setObjectData: (data: DataObject) => void;
}

export const dataStore = create<StoreState & StoreActions>((set) => {
  const initialState: StoreState = {
    objectData: { description: '' },
  };

  return {
    ...initialState,
    setObjectData: (data: DataObject) =>
      set((state: StoreState) => ({ ...state, objectData: data })),
  };
});

import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';
import { registerMerchantWindow } from './MerchantWindow';
import { registerMiningModal } from './MiningModal';
import { registerObjectModal } from './ObjectModal';
import { registerInventory } from './Inventory';
import { registerPetList } from './PetList';
import { registerRequestQueue } from './RequestQueue';
import { registerTradeWindow } from './TradeWindow';

export function registerUIComponents() {
  registerObjectModal();
  registerInventory();
  registerPetList();
  registerActionQueue();
  registerLoadingState();
  registerMerchantWindow();
  registerMiningModal();
  registerRequestQueue();
  registerTradeWindow();
}

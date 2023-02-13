import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';
import { registerMerchantWindow } from './MerchantWindow';
import { registerMiningModal } from './MiningModal';
import { registerObjectModal } from './ObjectModal';
import { registerRequestQueue } from './RequestQueue';
import { registerTradeWindow } from './TradeWindow';

export function registerUIComponents() {
  registerActionQueue();
  registerLoadingState();
  registerMerchantWindow();
  registerMiningModal();
  registerObjectModal();
  registerRequestQueue();
  registerTradeWindow();
}

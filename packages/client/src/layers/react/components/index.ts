import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';
import { registerMerchantWindow } from './MerchantWindow';
import { registerMiningModal } from './MiningModal';
import { registerObjectModal } from './ObjectModal';
import { registerInventory } from './Inventory';
import { registerInventoryButton } from './InventoryButton';
import { registerMyKamiButton } from './MyKamiButton';
import { registerChatButton } from './ChatButton';
import { registerPetList } from './PetList';
import { registerRequestQueue } from './RequestQueue';
import { registerTradeWindow } from './TradeWindow';
import { registerDetectMint } from './DetectMint';
import { registerMintProcess } from './MintProcess';

export function registerUIComponents() {
  registerLoadingState();
  registerDetectMint();
  registerInventory();
  registerPetList();
  registerMerchantWindow();
  registerMiningModal();
  registerRequestQueue();
  registerTradeWindow();
  registerInventoryButton();
  registerMyKamiButton();
  registerChatButton();
  registerObjectModal();
  registerMintProcess();
  registerActionQueue();
}

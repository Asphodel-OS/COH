import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';
import { registerMerchantWindow } from './MerchantWindow';
import { registerMiningModal } from './MiningModal';
import { registerObjectModal } from './ObjectModal';
import { registerMyKamiButton } from './MyKamiButton';
import { registerChatButton } from './ChatButton';
import { registerPetList } from './PetList';
import { registerRequestQueue } from './RequestQueue';
import { registerTradeWindow } from './TradeWindow';
import { registerDetectMint } from './DetectMint';
import { registerMintProcess } from './MintProcess';
import { registerChat } from './Chat';

export function registerUIComponents() {
  registerLoadingState();
  registerDetectMint();
  registerPetList();
  registerMerchantWindow();
  registerMiningModal();
  registerRequestQueue();
  registerTradeWindow();
  registerMyKamiButton();
  registerChatButton();
  registerObjectModal();
  registerMintProcess();
  registerChat();
  registerActionQueue();
}

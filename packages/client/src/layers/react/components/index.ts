import { registerActionQueue } from './ActionQueue';
import { registerLoadingState } from './LoadingState';
import { registerObjectModal } from './ObjectModal';

export function registerUIComponents() {
  registerLoadingState();
  registerObjectModal();
  registerActionQueue();
}

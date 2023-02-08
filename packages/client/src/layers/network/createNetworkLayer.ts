import { createFaucetService } from "@latticexyz/network";
import { createWorld } from "@latticexyz/recs";
import { createActionSystem, defineNumberComponent, setupMUDNetwork } from "@latticexyz/std-client";
import { SystemTypes } from "../../../types/SystemTypes";
import { SystemAbis } from "../../../types/SystemAbis.mjs";
import { GameConfig, getNetworkConfig } from "./config";
import { defineLoadingStateComponent } from "./components/definitions/LoadingStateComponent";
import { createAdminAPI } from "./api/admin";
import { createComponents } from "./components/register";

export async function createNetworkLayer(config: GameConfig) {
  const world = createWorld();
  const components = createComponents(world);

  const {
    txQueue,
    systems,
    txReduced$,
    network,
    startSync,
  } = await setupMUDNetwork<typeof components, SystemTypes>(getNetworkConfig(config), world, components, SystemAbis, {
    initialGasPrice: 2_000_000_000,
    fetchSystemCalls: true,
  });

  // --- ACTION SYSTEM --------------------------------------------------------------
  const actions = createActionSystem(world, txReduced$);

  // --- API ------------------------------------------------------------------------
  const faucet = config.faucetServiceUrl ? createFaucetService(config.faucetServiceUrl) : undefined;
  const address = network.connectedAddress.get();
  address && (await faucet?.dripDev({ address }));
  async function dripDev() {
    console.info("[Dev Faucet] Dripping funds to player");
    const address = network.connectedAddress.get();
    return address && faucet?.dripDev({ address });
  }

  const adminAPI = createAdminAPI(systems);


  // --- CONTEXT --------------------------------------------------------------------
  const context = {
    world,
    components,
    txQueue,
    systems,
    txReduced$,
    startSync,
    network,
    actions,
    api: {
      admin: adminAPI,
    },
    faucet,
  };

  return context;
}

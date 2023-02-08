/* eslint-disable prefer-const */
import React from 'react';
import ReactDOM from 'react-dom/client';
import { registerUIComponents as registerUIComponentsImport } from './layers/react/components';
import { Engine as EngineImport } from './layers/react/engine/Engine';
import { createNetworkLayer as createNetworkLayerImport } from './layers/network/createNetworkLayer';
import { createPhaserLayer as createPhaserLayerImport } from './layers/phaser/createPhaserLayer';
import { Layers } from './types';
import {
  getComponentValue,
  removeComponent,
  setComponent,
} from '@latticexyz/recs';
import { Time } from './utils/time';
import { Wallet } from 'ethers';

let createNetworkLayer = createNetworkLayerImport;
let createPhaserLayer = createPhaserLayerImport;
let registerUIComponents = registerUIComponentsImport;
let Engine = EngineImport;

async function bootGame() {
  const layers: Partial<Layers> = {};
  let initialBoot = true;

  async function rebootGame(): Promise<Layers> {
    mountReact.current(false);

    const params = new URLSearchParams(window.location.search);
    let worldAddress,
      wallet,
      chainIdString,
      jsonRpc,
      wsRpc,
      checkpointUrl,
      initialBlockNumber;
    let relayServiceUrl = '',
      faucetServiceUrl = '',
      snapshotUrl = '';

    const devMode = params.get('dev') === 'true';

    // LOCAL
    if (devMode) {
      worldAddress = params.get('worldAddress');
      chainIdString = params.get('chainId');
      jsonRpc = params.get('rpc') || undefined;
      wsRpc = params.get('wsRpc') || undefined; // || (jsonRpc && jsonRpc.replace("http", "ws"));
      checkpointUrl = params.get('checkpoint') || undefined;
      snapshotUrl = params.get('snapshotUrl') || '';
      let initialBlockNumberString = params.get('initialBlockNumber');
      initialBlockNumber = initialBlockNumberString
        ? parseInt(initialBlockNumberString)
        : 0;

      wallet = new Wallet(
        '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
      );
      localStorage.setItem('burnerPrivateKey', wallet.privateKey);
      localStorage.setItem('burnerAddress', wallet.publicKey);

      // TESTNET
    } else {
      relayServiceUrl = "https://ecs-relay.testnet-mud-services.linfra.xyz";
      faucetServiceUrl = "https://faucet.testnet-mud-services.linfra.xyz";
      snapshotUrl = "https://ecs-snapshot.testnet-mud-services.linfra.xyz";
      jsonRpc = "https://follower.testnet-chain.linfra.xyz";
      wsRpc = "wss://follower.testnet-chain.linfra.xyz";
      worldAddress = "0xfEF57aF100788255165c470621d19d4673e9ED91";
      chainIdString = "4242";
      checkpointUrl = params.get("checkpoint") || undefined;
      // let initialBlockNumberString = params.get("initialBlockNumber") || (testnet ? "474980" : "0");
      // initialBlockNumber = initialBlockNumberString ? parseInt(initialBlockNumberString) : 0;
      initialBlockNumber = 0;

      let privateKey = localStorage.getItem("burnerWallet")
      wallet = privateKey ? new Wallet(privateKey) : Wallet.createRandom();
      localStorage.setItem("burnerWallet", wallet.privateKey);
      localStorage.setItem("burnerWalletAddress", wallet.publicKey);
    }

    let networkLayerConfig;
    if (worldAddress && wallet && chainIdString && jsonRpc) {
      networkLayerConfig = {
        worldAddress,
        privateKey: wallet.privateKey,
        chainId: parseInt(chainIdString),
        jsonRpc,
        wsRpc,
        checkpointUrl,
        devMode,
        initialBlockNumber,
        faucetServiceUrl,
        relayServiceUrl,
        snapshotUrl,
      };
    }

    if (!networkLayerConfig) throw new Error('Invalid config');

    if (!layers.network)
      layers.network = await createNetworkLayer(networkLayerConfig);
    if (!layers.phaser) layers.phaser = await createPhaserLayer(layers.network);

    Time.time.setPacemaker((setTimestamp) => {
      layers.phaser?.game.events.on('poststep', (time: number) => {
        setTimestamp(time);
      });
    });

    if (document.querySelectorAll('#phaser-game canvas').length > 1) {
      console.log('Detected two canvas elements, full reload');
    }

    if (initialBoot) {
      initialBoot = false;
      layers.network.startSync();
    }

    mountReact.current(true);

    return layers as Layers;
  }

  await rebootGame();

  const ecs = {
    setComponent,
    removeComponent,
    getComponentValue,
  };

  (window as any).layers = layers;
  (window as any).ecs = ecs;
  (window as any).time = Time.time;

  console.log('booted');

  return { layers, ecs };
}

const mountReact: { current: (mount: boolean) => void } = {
  current: () => void 0,
};
const setLayers: { current: (layers: Layers) => void } = {
  current: () => void 0,
};

function bootReact() {
  const rootElement = document.getElementById('react-root');
  if (!rootElement) return console.warn('React root not found');

  const root = ReactDOM.createRoot(rootElement);

  function renderEngine() {
    root.render(<Engine setLayers={setLayers} mountReact={mountReact} />);
  }

  renderEngine();
  registerUIComponents();
}

export async function boot() {
  bootReact();
  const game = await bootGame();
  setLayers.current(game.layers as Layers);
}

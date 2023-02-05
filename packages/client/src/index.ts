import { setupMUDNetwork } from "@latticexyz/std-client";
import { createWorld } from "@latticexyz/recs";
import { SystemTypes } from "client/types/SystemTypes";
import { SystemAbis } from "client/types/SystemAbis.mjs";
import { defineNumberComponent } from "@latticexyz/std-client";
import { config } from "./config";
import { Engine as EngineImport } from "./PhaserEngine.tsx";

const world = createWorld();

const components = {
  Counter: defineNumberComponent(world, {
    metadata: {
      contractId: "component.Counter",
    },
  }),
};

function bootReact() {
  const rootElement = document.getElementById("react-root");
  if (!rootElement) return console.warn("React root not found");

  const root = ReactDOM.createRoot(rootElement);
}

setupMUDNetwork<typeof components, SystemTypes>(
  config,
  world,
  components,
  SystemAbis
).then(({ startSync, systems }) => {
  startSync();
  (window as any).increment = () =>
    systems["system.Increment"].executeTyped("0x00");
});

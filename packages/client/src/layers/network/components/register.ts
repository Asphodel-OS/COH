import {
  defineBoolComponent,
  defineNumberComponent,
  defineStringComponent,
} from "@latticexyz/std-client";

import {
  defineLoadingStateComponent,
  defineNumberArrayComponent,
} from "./definitions";

// define functions for registration
export function createComponents(world: any) {
  return {
    // TODO: deprecate these once character has been made obsolete
    IsCharacter: defineBoolComponent(world, { id: "IsCharacter", metadata: { contractId: "component.Is.Character" } }),
    CharacterID: defineStringComponent(world, { id: "CharacterID", metadata: { contractId: "component.Id.Character" } }),

    // identifiers
    IsInventory: defineBoolComponent(world, { id: "IsInventory", metadata: { contractId: "component.Is.Inventory" } }),
    IsListing: defineBoolComponent(world, { id: "IsListing", metadata: { contractId: "component.Is.Listing" } }),
    IsMerchant: defineBoolComponent(world, { id: "IsMerchant", metadata: { contractId: "component.Is.Merchant" } }),
    IsNode: defineBoolComponent(world, { id: "IsNode", metadata: { contractId: "component.Is.Node" } }),
    IsOperator: defineBoolComponent(world, { id: "IsOperator", metadata: { contractId: "component.Is.Operator" } }),
    IsPet: defineBoolComponent(world, { id: "IsPet", metadata: { contractId: "component.Is.Pet" } }),
    IsProduction: defineBoolComponent(world, { id: "IsProduction", metadata: { contractId: "component.Is.Production" } }),
    IsRegistryEntry: defineBoolComponent(world, { id: "IsRegistryEntry", metadata: { contractId: "component.Is.RegistryEntry" } }),
    IsRoom: defineBoolComponent(world, { id: "IsRoom", metadata: { contractId: "component.Is.Room" } }),

    // IDs
    MerchantID: defineStringComponent(world, { id: "MerchantID", metadata: { contractId: "component.Id.Merchant" } }),
    NodeID: defineStringComponent(world, { id: "NodeID", metadata: { contractId: "component.Id.Node" } }),
    OperatorID: defineStringComponent(world, { id: "OperatorID", metadata: { contractId: "component.Id.Operator" } }),
    OwnerID: defineStringComponent(world, { id: "OwnerID", metadata: { contractId: "component.Id.Owner" } }),
    PetID: defineStringComponent(world, { id: "PetID", metadata: { contractId: "component.Id.Pet" } }),

    // Indices
    ItemIndex: defineNumberComponent(world, { id: "ItemIndex", metadata: { contractId: "component.Index.Item" } }),
    ModifierIndex: defineNumberComponent(world, { id: "ModifierIndex", metadata: { contractId: "component.Index.Modifier" } }),
    PetIndex: defineNumberComponent(world, { id: "PetIndex", metadata: { contractId: "component.Index.Pet" } }),

    // values
    Balance: defineNumberComponent(world, { id: "Balance", metadata: { contractId: "component.Balance" } }),
    BlockLast: defineNumberComponent(world, { id: "BlockLast", metadata: { contractId: "component.BlockLast" } }),
    Coin: defineNumberComponent(world, { id: "Coin", metadata: { contractId: "component.Coin" } }),
    Exits: defineNumberArrayComponent(world, "Exits", "component.Exits"),
    HashRate: defineNumberComponent(world, { id: "HashRate", metadata: { contractId: "component.HashRate" } }),
    Location: defineNumberComponent(world, { id: "Location", metadata: { contractId: "component.Location" } }),
    ModifierStatus: defineStringComponent(world, { id: "ModifierStatus", metadata: { contractId: "component.ModifierStatus" } }),
    ModifierType: defineStringComponent(world, { id: "ModifierType", metadata: { contractId: "component.ModifierType" } }),
    ModifierValue: defineStringComponent(world, { id: "ModifierValue", metadata: { contractId: "component.ModifierValue" } }),
    Name: defineStringComponent(world, { id: "Name", metadata: { contractId: "component.Name" } }),
    NumCores: defineNumberComponent(world, { id: "NumCores", metadata: { contractId: "component.NumCores" } }),
    PriceBuy: defineNumberComponent(world, { id: "PriceBuy", metadata: { contractId: "component.PriceBuy" } }),
    PriceSell: defineNumberComponent(world, { id: "PriceSell", metadata: { contractId: "component.PriceBuy" } }),
    State: defineStringComponent(world, { id: "State", metadata: { contractId: "component.State" } }),
    StorageSize: defineNumberComponent(world, { id: "StorageSize", metadata: { contractId: "component.StorageSize" } }),
    TimeLastAction: defineNumberComponent(world, { id: "TimeLastAction", metadata: { contractId: "component.TimeLastAction" } }),
    TimeStart: defineNumberComponent(world, { id: "TimeStart", metadata: { contractId: "component.TimeStart" } }),


    // speecial
    LoadingState: defineLoadingStateComponent(world),
    MediaURI: defineStringComponent(world, { id: "MediaURI", metadata: { contractId: "component.MediaURI" } }),
  }
}
import {
  defineBoolComponent,
  defineNumberComponent,
  defineStringComponent,
} from "@latticexyz/std-client";

import {
  defineLoadingStateComponent,
  defineNumberArrayComponent,
  defineStringArrayComponent,
} from "./definitions";

// define functions for registration
export function createComponents(world: any) {
  return {
    // Archetypes
    IsInventory: defineBoolComponent(world, { id: "IsInventory", metadata: { contractId: "component.Is.Inventory" } }),
    IsListing: defineBoolComponent(world, { id: "IsListing", metadata: { contractId: "component.Is.Listing" } }),
    IsMerchant: defineBoolComponent(world, { id: "IsMerchant", metadata: { contractId: "component.Is.Merchant" } }),
    IsModifier: defineBoolComponent(world, { id: "IsModifier", metadata: { contractId: "component.Is.Modifier" } }),
    IsNode: defineBoolComponent(world, { id: "IsNode", metadata: { contractId: "component.Is.Node" } }),
    IsOperator: defineBoolComponent(world, { id: "IsOperator", metadata: { contractId: "component.Is.Operator" } }),
    IsPet: defineBoolComponent(world, { id: "IsPet", metadata: { contractId: "component.Is.Pet" } }),
    IsProduction: defineBoolComponent(world, { id: "IsProduction", metadata: { contractId: "component.Is.Production" } }),
    IsRegister: defineBoolComponent(world, { id: "IsRegister", metadata: { contractId: "component.Is.Register" } }),
    IsRegistryEntry: defineBoolComponent(world, { id: "IsRegistryEntry", metadata: { contractId: "component.Is.RegistryEntry" } }),
    IsRequest: defineBoolComponent(world, { id: "IsRequest", metadata: { contractId: "component.Is.Request" } }),
    IsRoom: defineBoolComponent(world, { id: "IsRoom", metadata: { contractId: "component.Is.Room" } }),
    IsTrade: defineBoolComponent(world, { id: "IsTrade", metadata: { contractId: "component.Is.Trade" } }),

    // IDs
    DelegateeID: defineStringComponent(world, { id: "DelegateeID", metadata: { contractId: "component.Id.Delegatee" } }),
    DelegatorID: defineStringComponent(world, { id: "DelegatorID", metadata: { contractId: "component.Id.Delegator" } }),
    HolderID: defineStringComponent(world, { id: "HolderID", metadata: { contractId: "component.Id.Holder" } }),
    MerchantID: defineStringComponent(world, { id: "MerchantID", metadata: { contractId: "component.Id.Merchant" } }),
    NodeID: defineStringComponent(world, { id: "NodeID", metadata: { contractId: "component.Id.Node" } }),
    OperatorID: defineStringComponent(world, { id: "OperatorID", metadata: { contractId: "component.Id.Operator" } }),
    OwnerID: defineStringComponent(world, { id: "OwnerID", metadata: { contractId: "component.Id.Owner" } }),
    RequesteeID: defineStringComponent(world, { id: "RequesteeID", metadata: { contractId: "component.Id.Requestee" } }),
    RequesterID: defineStringComponent(world, { id: "RequesterID", metadata: { contractId: "component.Id.Requester" } }),
    PetID: defineStringComponent(world, { id: "PetID", metadata: { contractId: "component.Id.Pet" } }),

    // Indices
    ItemIndex: defineNumberComponent(world, { id: "ItemIndex", metadata: { contractId: "component.Index.Item" } }),
    ModifierIndex: defineNumberComponent(world, { id: "ModifierIndex", metadata: { contractId: "component.Index.Modifier" } }),
    Genus: defineStringComponent(world, { id: "Genus", metadata: { contractId: "component.Index.Genus" } }),
    PetIndex: defineStringComponent(world, { id: "PetIndex", metadata: { contractId: "component.Index.Pet" } }),

    // Values
    Balance: defineNumberComponent(world, { id: "Balance", metadata: { contractId: "component.Balance" } }),
    Bandwidth: defineNumberComponent(world, { id: "Bandwidth", metadata: { contractId: "component.Bandwidth" } }),
    BlockLast: defineNumberComponent(world, { id: "BlockLast", metadata: { contractId: "component.BlockLast" } }),
    Capacity: defineNumberComponent(world, { id: "Capacity", metadata: { contractId: "component.Capacity" } }),
    Charge: defineNumberComponent(world, { id: "Charge", metadata: { contractId: "component.Charge" } }),
    Coin: defineNumberComponent(world, { id: "Coin", metadata: { contractId: "component.Coin" } }),
    Exits: defineNumberArrayComponent(world, "Exits", "component.Exits"),
    Location: defineNumberComponent(world, { id: "Location", metadata: { contractId: "component.Location" } }),
    ModifierStatus: defineStringComponent(world, { id: "ModifierStatus", metadata: { contractId: "component.ModifierStatus" } }),
    ModifierType: defineStringComponent(world, { id: "ModifierType", metadata: { contractId: "component.ModifierType" } }),
    ModifierValue: defineStringComponent(world, { id: "ModifierValue", metadata: { contractId: "component.ModifierValue" } }),
    PriceBuy: defineNumberComponent(world, { id: "PriceBuy", metadata: { contractId: "component.PriceBuy" } }),
    PriceSell: defineNumberComponent(world, { id: "PriceSell", metadata: { contractId: "component.PriceSell" } }),
    State: defineStringComponent(world, { id: "State", metadata: { contractId: "component.State" } }),
    StorageSize: defineNumberComponent(world, { id: "StorageSize", metadata: { contractId: "component.StorageSize" } }),

    // Times
    LastActionTime: defineNumberComponent(world, { id: "LastActionTime", metadata: { contractId: "component.time.LastAction" } }),
    StartTime: defineNumberComponent(world, { id: "StartTime", metadata: { contractId: "component.time.Start" } }),

    // speeeecial
    LoadingState: defineLoadingStateComponent(world),
    MediaURI: defineStringComponent(world, { id: "MediaURI", metadata: { contractId: "component.MediaURI" } }),
    Name: defineStringComponent(world, { id: "Name", metadata: { contractId: "component.Name" } }),
    PlayerAddress: defineStringComponent(world, { id: "PlayerAddress", metadata: { contractId: "component.AddressPlayer" } }),
  }
}
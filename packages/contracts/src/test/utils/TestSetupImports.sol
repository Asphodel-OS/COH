// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "std-contracts/test/MudTest.t.sol";

// Libraries
import "libraries/LibOperator.sol";
import "libraries/LibCoin.sol";
import "libraries/LibInventory.sol";
import "libraries/LibMerchant.sol";
import "libraries/LibNode.sol";
import "libraries/LibPet.sol";
import "libraries/LibProduction.sol";
import "libraries/LibRoom.sol";

// Components
import { BalanceComponent, ID as BalanceComponentID } from "components/BalanceComponent.sol";
import { CoinComponent, ID as CoinComponentID } from "components/CoinComponent.sol";
import { ExitsComponent, ID as ExitsComponentID } from "components/ExitsComponent.sol";
import { HashRateComponent, ID as HashRateComponentID } from "components/HashRateComponent.sol";
import { IdMerchantComponent, ID as IdMerchantComponentID } from "components/IdMerchantComponent.sol";
import { IdNodeComponent, ID as IdNodeComponentID } from "components/IdNodeComponent.sol";
import { IdOperatorComponent, ID as IdOperatorComponentID } from "components/IdOperatorComponent.sol";
import { IdOwnerComponent, ID as IdOwnerComponentID } from "components/IdOwnerComponent.sol";
import { IdPetComponent, ID as IdPetComponentID } from "components/IdPetComponent.sol";
import { IndexItemComponent, ID as IndexItemComponentID } from "components/IndexItemComponent.sol";
import { IndexModifierComponent, ID as IndexModifierComponentID } from "components/IndexModifierComponent.sol";
import { IndexPetComponent, ID as IndexPetComponentID } from "components/IndexPetComponent.sol";
import { IsInventoryComponent, ID as IsInventoryComponentID } from "components/IsInventoryComponent.sol";
import { IsMerchantComponent, ID as IsMerchantComponentID } from "components/IsMerchantComponent.sol";
import { IsNodeComponent, ID as IsNodeComponentID } from "components/IsNodeComponent.sol";
import { IsOperatorComponent, ID as IsOperatorComponentID } from "components/IsOperatorComponent.sol";
import { IsPetComponent, ID as IsPetComponentID } from "components/IsPetComponent.sol";
import { IsProductionComponent, ID as IsProductionComponentID } from "components/IsProductionComponent.sol";
import { IsRegistryEntryComponent, ID as IsRegistryEntryComponentID } from "components/IsRegistryEntryComponent.sol";
import { IsRoomComponent, ID as IsRoomComponentID } from "components/IsRoomComponent.sol";
import { LocationComponent, ID as LocationComponentID } from "components/LocationComponent.sol";
import { MediaURIComponent, ID as MediaURIComponentID } from "components/MediaURIComponent.sol";
import { ModifierStatusComponent, ID as ModifierStatusComponentID } from "components/ModifierStatusComponent.sol";
import { ModifierTypeComponent, ID as ModifierTypeComponentID } from "components/ModifierTypeComponent.sol";
import { ModifierValueComponent, ID as ModifierValueComponentID } from "components/ModifierValueComponent.sol";
import { NameComponent, ID as NameComponentID } from "components/NameComponent.sol";
import { NumCoresComponent, ID as NumCoresComponentID } from "components/NumCoresComponent.sol";
import { PriceBuyComponent, ID as PriceBuyComponentID } from "components/PriceBuyComponent.sol";
import { PriceSellComponent, ID as PriceSellComponentID } from "components/PriceSellComponent.sol";
import { PrototypeComponent, ID as PrototypeComponentID } from "components/PrototypeComponent.sol";
import { StateComponent, ID as StateComponentID } from "components/StateComponent.sol";
import { StorageSizeComponent, ID as StorageSizeComponentID } from "components/StorageSizeComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionComponentID } from "components/TimeLastActionComponent.sol";
import { TimeStartComponent, ID as TimeStartComponentID } from "components/TimeStartComponent.sol";

// Systems
import { ERC721PetSystem, ID as ERC721PetSystemID } from "systems/ERC721PetSystem.sol";
import { ListingBuySystem, ID as ListingBuySystemID } from "systems/ListingBuySystem.sol";
import { ListingSellSystem, ID as ListingSellSystemID } from "systems/ListingSellSystem.sol";
import { ListingSetSystem, ID as ListingSetSystemID } from "systems/ListingSetSystem.sol";
import { MerchantCreateSystem, ID as MerchantCreateSystemID } from "systems/MerchantCreateSystem.sol";
import { NodeCreateSystem, ID as NodeCreateSystemID } from "systems/NodeCreateSystem.sol";
import { OperatorSetSystem, ID as OperatorSetSystemID } from "systems/OperatorSetSystem.sol";
import { ProductionCollectSystem, ID as ProductionCollectSystemID } from "systems/ProductionCollectSystem.sol";
import { ProductionStartSystem, ID as ProductionStartSystemID } from "systems/ProductionStartSystem.sol";
import { ProductionStopSystem, ID as ProductionStopSystemID } from "systems/ProductionStopSystem.sol";

abstract contract TestSetupImports is MudTest {
// Components vars
BalanceComponent _BalanceComponent;
CoinComponent _CoinComponent;
ExitsComponent _ExitsComponent;
HashRateComponent _HashRateComponent;
IdMerchantComponent _IdMerchantComponent;
IdNodeComponent _IdNodeComponent;
IdOperatorComponent _IdOperatorComponent;
IdOwnerComponent _IdOwnerComponent;
IdPetComponent _IdPetComponent;
IndexItemComponent _IndexItemComponent;
IndexModifierComponent _IndexModifierComponent;
IndexPetComponent _IndexPetComponent;
IsInventoryComponent _IsInventoryComponent;
IsMerchantComponent _IsMerchantComponent;
IsNodeComponent _IsNodeComponent;
IsOperatorComponent _IsOperatorComponent;
IsPetComponent _IsPetComponent;
IsProductionComponent _IsProductionComponent;
IsRegistryEntryComponent _IsRegistryEntryComponent;
IsRoomComponent _IsRoomComponent;
LocationComponent _LocationComponent;
MediaURIComponent _MediaURIComponent;
ModifierStatusComponent _ModifierStatusComponent;
ModifierTypeComponent _ModifierTypeComponent;
ModifierValueComponent _ModifierValueComponent;
NameComponent _NameComponent;
NumCoresComponent _NumCoresComponent;
PriceBuyComponent _PriceBuyComponent;
PriceSellComponent _PriceSellComponent;
PrototypeComponent _PrototypeComponent;
StateComponent _StateComponent;
StorageSizeComponent _StorageSizeComponent;
TimeLastActionComponent _TimeLastActionComponent;
TimeStartComponent _TimeStartComponent;

// System vars
ERC721PetSystem _ERC721PetSystem;
ListingBuySystem _ListingBuySystem;
ListingSellSystem _ListingSellSystem;
ListingSetSystem _ListingSetSystem;
MerchantCreateSystem _MerchantCreateSystem;
NodeCreateSystem _NodeCreateSystem;
OperatorSetSystem _OperatorSetSystem;
ProductionCollectSystem _ProductionCollectSystem;
ProductionStartSystem _ProductionStartSystem;
ProductionStopSystem _ProductionStopSystem;

function setUp() public virtual override {
super.setUp();

_BalanceComponent = BalanceComponent(component(BalanceComponentID));
_CoinComponent = CoinComponent(component(CoinComponentID));
_ExitsComponent = ExitsComponent(component(ExitsComponentID));
_HashRateComponent = HashRateComponent(component(HashRateComponentID));
_IdMerchantComponent = IdMerchantComponent(component(IdMerchantComponentID));
_IdNodeComponent = IdNodeComponent(component(IdNodeComponentID));
_IdOperatorComponent = IdOperatorComponent(component(IdOperatorComponentID));
_IdOwnerComponent = IdOwnerComponent(component(IdOwnerComponentID));
_IdPetComponent = IdPetComponent(component(IdPetComponentID));
_IndexItemComponent = IndexItemComponent(component(IndexItemComponentID));
_IndexModifierComponent = IndexModifierComponent(component(IndexModifierComponentID));
_IndexPetComponent = IndexPetComponent(component(IndexPetComponentID));
_IsInventoryComponent = IsInventoryComponent(component(IsInventoryComponentID));
_IsMerchantComponent = IsMerchantComponent(component(IsMerchantComponentID));
_IsNodeComponent = IsNodeComponent(component(IsNodeComponentID));
_IsOperatorComponent = IsOperatorComponent(component(IsOperatorComponentID));
_IsPetComponent = IsPetComponent(component(IsPetComponentID));
_IsProductionComponent = IsProductionComponent(component(IsProductionComponentID));
_IsRegistryEntryComponent = IsRegistryEntryComponent(component(IsRegistryEntryComponentID));
_IsRoomComponent = IsRoomComponent(component(IsRoomComponentID));
_LocationComponent = LocationComponent(component(LocationComponentID));
_MediaURIComponent = MediaURIComponent(component(MediaURIComponentID));
_ModifierStatusComponent = ModifierStatusComponent(component(ModifierStatusComponentID));
_ModifierTypeComponent = ModifierTypeComponent(component(ModifierTypeComponentID));
_ModifierValueComponent = ModifierValueComponent(component(ModifierValueComponentID));
_NameComponent = NameComponent(component(NameComponentID));
_NumCoresComponent = NumCoresComponent(component(NumCoresComponentID));
_PriceBuyComponent = PriceBuyComponent(component(PriceBuyComponentID));
_PriceSellComponent = PriceSellComponent(component(PriceSellComponentID));
_PrototypeComponent = PrototypeComponent(component(PrototypeComponentID));
_StateComponent = StateComponent(component(StateComponentID));
_StorageSizeComponent = StorageSizeComponent(component(StorageSizeComponentID));
_TimeLastActionComponent = TimeLastActionComponent(component(TimeLastActionComponentID));
_TimeStartComponent = TimeStartComponent(component(TimeStartComponentID));

_ERC721PetSystem = ERC721PetSystem(system(ERC721PetSystemID));
_ListingBuySystem = ListingBuySystem(system(ListingBuySystemID));
_ListingSellSystem = ListingSellSystem(system(ListingSellSystemID));
_ListingSetSystem = ListingSetSystem(system(ListingSetSystemID));
_MerchantCreateSystem = MerchantCreateSystem(system(MerchantCreateSystemID));
_NodeCreateSystem = NodeCreateSystem(system(NodeCreateSystemID));
_OperatorSetSystem = OperatorSetSystem(system(OperatorSetSystemID));
_ProductionCollectSystem = ProductionCollectSystem(system(ProductionCollectSystemID));
_ProductionStartSystem = ProductionStartSystem(system(ProductionStartSystemID));
_ProductionStopSystem = ProductionStopSystem(system(ProductionStopSystemID));
}
}
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "std-contracts/test/MudTest.t.sol";

// Libraries 
import "../libraries/LibCharacter.sol";
import "../libraries/LibCoin.sol";
import "../libraries/LibInventory.sol";
import "../libraries/LibMerchant.sol";
import "../libraries/LibNode.sol";
import "../libraries/LibPet.sol";
import "../libraries/LibProduction.sol";
import "../libraries/LibRoom.sol";

// Components
import { BalanceComponent, ID as BalanceComponentID } from "../components/BalanceComponent.sol";
import { CoinComponent, ID as CoinComponentID } from "../components/CoinComponent.sol";
import { ExitsComponent, ID as ExitsComponentID } from "../components/ExitsComponent.sol";
import { ERC721EntityIndexPetComponent, ID as ERC721EntityIndexPetComponentID } from "../components/ERC721EntityIndexPetComponent.sol";
import { ERC721OwnedByPetComponent, ID as ERC721OwnedByPetComponentID } from "../components/ERC721OwnedByPetComponent.sol";
import { IdCharacterComponent, ID as IdCharacterComponentID } from "../components/IdCharacterComponent.sol";
import { IdMerchantComponent, ID as IdMerchantComponentID } from "../components/IdMerchantComponent.sol";
import { IdOwnerComponent, ID as IdOwnerComponentID } from "../components/IdOwnerComponent.sol";
import { IdPetComponent, ID as IdPetComponentID } from "../components/IdPetComponent.sol";
import { IndexItemComponent, ID as IndexItemComponentID } from "../components/IndexItemComponent.sol";
import { IsCharacterComponent, ID as IsCharacterComponentID } from "../components/IsCharacterComponent.sol";
import { IsInventoryComponent, ID as IsInventoryComponentID } from "../components/IsInventoryComponent.sol";
import { IsMerchantComponent, ID as IsMerchantComponentID } from "../components/IsMerchantComponent.sol";
import { IsNodeComponent, ID as IsNodeComponentID } from "../components/IsNodeComponent.sol";
import { IsPetComponent, ID as IsPetComponentID } from "../components/IsPetComponent.sol";
import { IsProductionComponent, ID as IsProductionComponentID } from "../components/IsProductionComponent.sol";
import { IsRegistryEntryComponent, ID as IsRegistryEntryComponentID } from "../components/IsRegistryEntryComponent.sol";
import { IsRoomComponent, ID as IsRoomComponentID } from "../components/IsRoomComponent.sol";
import { LocationComponent, ID as LocationComponentID } from "../components/LocationComponent.sol";
import { NameComponent, ID as NameComponentID } from "../components/NameComponent.sol";
import { MediaURIComponent, ID as MediaURIComponentID } from "../components/MediaURIComponent.sol";
import { OperatorComponent, ID as OperatorComponentID } from "../components/OperatorComponent.sol";
import { PriceBuyComponent, ID as PriceBuyComponentID } from "../components/PriceBuyComponent.sol";
import { PriceSellComponent, ID as PriceSellComponentID } from "../components/PriceSellComponent.sol";
import { StateComponent, ID as StateComponentID } from "../components/StateComponent.sol";
import { TimeLastActionComponent, ID as TimeLastActionComponentID } from "../components/TimeLastActionComponent.sol";

// Systems
import { ERC721PetSystem, ID as ERC721PetSystemID } from "../systems/ERC721PetSystem.sol";
import { ListingBuySystem, ID as ListingBuySystemID } from "../systems/ListingBuySystem.sol";
import { ListingSellSystem, ID as ListingSellSystemID } from "../systems/ListingSellSystem.sol";
import { ListingSetSystem, ID as ListingSetSystemID } from "../systems/ListingSetSystem.sol";
import { MerchantCreateSystem, ID as MerchantCreateSystemID } from "../systems/MerchantCreateSystem.sol";

contract TestSetupImports is MudTest {
  // Components vars
      BalanceComponent _BalanceComponent;
      CoinComponent _CoinComponent;
      ExitsComponent _ExitsComponent;
      ERC721EntityIndexPetComponent _ERC721EntityIndexPetComponent;
      ERC721OwnedByPetComponent _ERC721OwnedByPetComponent;
      IdCharacterComponent _IdCharacterComponent;
      IdMerchantComponent _IdMerchantComponent;
      IdOwnerComponent _IdOwnerComponent;
      IdPetComponent _IdPetComponent;
      IndexItemComponent _IndexItemComponent;
      IsCharacterComponent _IsCharacterComponent;
      IsInventoryComponent _IsInventoryComponent;
      IsMerchantComponent _IsMerchantComponent;
      IsNodeComponent _IsNodeComponent;
      IsPetComponent _IsPetComponent;
      IsProductionComponent _IsProductionComponent;
      IsRegistryEntryComponent _IsRegistryEntryComponent;
      IsRoomComponent _IsRoomComponent;
      LocationComponent _LocationComponent;
      NameComponent _NameComponent;
      MediaURIComponent _MediaURIComponent;
      OperatorComponent _OperatorComponent;
      PriceBuyComponent _PriceBuyComponent;
      PriceSellComponent _PriceSellComponent;
      StateComponent _StateComponent;
      TimeLastActionComponent _TimeLastActionComponent;
   

  // System vars
      ERC721PetSystem _ERC721PetSystem;
      ListingBuySystem _ListingBuySystem;
      ListingSellSystem _ListingSellSystem;
      ListingSetSystem _ListingSetSystem;
      MerchantCreateSystem _MerchantCreateSystem;
   

  function setUp() public virtual override {
    super.setUp();

          _BalanceComponent = BalanceComponent(component(BalanceComponentID));
          _CoinComponent = CoinComponent(component(CoinComponentID));
          _ExitsComponent = ExitsComponent(component(ExitsComponentID));
          _ERC721EntityIndexPetComponent = ERC721EntityIndexPetComponent(component(ERC721EntityIndexPetComponentID));
          _ERC721OwnedByPetComponent = ERC721OwnedByPetComponent(component(ERC721OwnedByPetComponentID));
          _IdCharacterComponent = IdCharacterComponent(component(IdCharacterComponentID));
          _IdMerchantComponent = IdMerchantComponent(component(IdMerchantComponentID));
          _IdOwnerComponent = IdOwnerComponent(component(IdOwnerComponentID));
          _IdPetComponent = IdPetComponent(component(IdPetComponentID));
          _IndexItemComponent = IndexItemComponent(component(IndexItemComponentID));
          _IsCharacterComponent = IsCharacterComponent(component(IsCharacterComponentID));
          _IsInventoryComponent = IsInventoryComponent(component(IsInventoryComponentID));
          _IsMerchantComponent = IsMerchantComponent(component(IsMerchantComponentID));
          _IsNodeComponent = IsNodeComponent(component(IsNodeComponentID));
          _IsPetComponent = IsPetComponent(component(IsPetComponentID));
          _IsProductionComponent = IsProductionComponent(component(IsProductionComponentID));
          _IsRegistryEntryComponent = IsRegistryEntryComponent(component(IsRegistryEntryComponentID));
          _IsRoomComponent = IsRoomComponent(component(IsRoomComponentID));
          _LocationComponent = LocationComponent(component(LocationComponentID));
          _NameComponent = NameComponent(component(NameComponentID));
          _MediaURIComponent = MediaURIComponent(component(MediaURIComponentID));
          _OperatorComponent = OperatorComponent(component(OperatorComponentID));
          _PriceBuyComponent = PriceBuyComponent(component(PriceBuyComponentID));
          _PriceSellComponent = PriceSellComponent(component(PriceSellComponentID));
          _StateComponent = StateComponent(component(StateComponentID));
          _TimeLastActionComponent = TimeLastActionComponent(component(TimeLastActionComponentID));
     
    
          _ERC721PetSystem = ERC721PetSystem(system(ERC721PetSystemID));
          _ListingBuySystem = ListingBuySystem(system(ListingBuySystemID));
          _ListingSellSystem = ListingSellSystem(system(ListingSellSystemID));
          _ListingSetSystem = ListingSetSystem(system(ListingSetSystemID));
          _MerchantCreateSystem = MerchantCreateSystem(system(MerchantCreateSystemID));
     
  }
}
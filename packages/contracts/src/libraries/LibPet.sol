// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { ERC721OwnedByPetComponent, ID as ERC721OwnedByPetComponentID } from "components/ERC721OwnedByPetComponent.sol";
import { ERC721EntityIndexPetComponent, ID as ERC721EntityIndexPetComponentID } from "components/ERC721EntityIndexPetComponent.sol";
import { MediaURIComponent, ID as MediaURIComponentID } from "components/MediaURIComponent.sol";
import { OperatorComponent, ID as OperatorComponentID } from "components/OperatorComponent.sol";
import { IdOwnerComponent, ID as IdOwnerCompID } from "components/IdOwnerComponent.sol";
import { HashRateComponent, ID as HashRateCompID } from "components/HashRateComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { StorageSizeComponent, ID as StorSizeCompID } from "components/StorageSizeComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";

library LibPet {
  // create an inventory entity for an entity
  function create(
    IWorld world,
    IUint256Component components,
    uint256 charID,
    uint256 hashRate,
    uint256 storageSize
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, charID);
    HashRateComponent(getAddressById(components, HashRateCompID)).set(id, hashRate);
    StorageSizeComponent(getAddressById(components, StorSizeCompID)).set(id, storageSize);
    return id;
  }

  /////////////////
  // CALCULATIONS

  // calculate and return the total storage size of a pet (including equipment)
  // TODO: include equipment
  function getTotalStorage(IUint256Component components, uint256 id)
    internal
    view
    returns (uint256)
  {
    return StorageSizeComponent(getAddressById(components, StorSizeCompID)).getValue(id);
  }

  // calculate and return the total hash rate of a pet (including equipment)
  // TODO: include equipment
  function getTotalHashRate(IUint256Component components, uint256 id)
    internal
    view
    returns (uint256)
  {
    return HashRateComponent(getAddressById(components, HashRateCompID)).getValue(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function name(
    IUint256Component components,
    uint256 id,
    string memory _name
  ) internal {
    NameComponent(getAddressById(components, NameCompID)).set(id, _name);
  }

  // get the owner of this pet
  function getOwner(IUint256Component components, uint256 id) internal view returns (uint256) {
    return IdOwnerComponent(getAddressById(components, IdOwnerCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // Get the production of a pet. Return 0 if there are none.
  function getNodeProduction(
    IUint256Component components,
    uint256 id,
    uint256 nodeID
  ) internal view returns (uint256 result) {
    uint256[] memory results = LibProduction._getAllX(components, nodeID, 0, id, "");
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get the production of a pet. Return 0 if there are none.
  // We can assume pets can only commit to one active production.
  function getActiveProduction(IUint256Component components, uint256 id)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = LibProduction._getAllX(components, 0, 0, id, "ACTIVE");
    if (results.length > 0) {
      result = results[0];
    }
  }

  /////////////////
  // ERC721

  // create pet
  function createPet(
    IUint256Component components,
    IWorld world,
    uint256 nftID,
    address sender
  ) internal returns (uint256) {
    uint256 entityID = world.getUniqueEntityId();
    
    ERC721EntityIndexPetComponent(
      getAddressById(components, ERC721EntityIndexPetComponentID)
    ).set(entityID, nftID);    
    ERC721OwnedByPetComponent(
      getAddressById(components, ERC721OwnedByPetComponentID)
    ).set(entityID, sender);
    OperatorComponent(
      getAddressById(components, OperatorComponentID)
    ).set(entityID, sender);

    return entityID;
  }

  // transfer ERC721 pet
  function transferPet(
    IUint256Component components,
    uint256 nftID,
    address to
  ) internal {
    // does not need to check for previous owner, ERC721 handles it

    uint256 entityID = nftToEntityID(components, nftID);

    ERC721OwnedByPetComponent(
      getAddressById(components, ERC721OwnedByPetComponentID)
    ).set(entityID, to);
    OperatorComponent(
      getAddressById(components, OperatorComponentID)
    ).set(entityID, to);
 
  }

  function nftToEntityID(
    IUint256Component components,
    uint256 tokenID
  ) internal view returns (uint256) {
    ERC721EntityIndexPetComponent indexComp = ERC721EntityIndexPetComponent(
      getAddressById(components, ERC721EntityIndexPetComponentID)
    );

    // no check if index exists; returning non existence will revert
    return indexComp.getEntitiesWithValue(tokenID)[0];
  }

  /////////////////
  // Auth

  // get pet owner
  function getPetOwner(
    IUint256Component components,
    uint256 entityID
  ) internal view returns (address) {
    ERC721OwnedByPetComponent ownedComp = ERC721OwnedByPetComponent(
      getAddressById(components, ERC721OwnedByPetComponentID)
    ); 

    // check if exists, can remove for optimisation
    require(ownedComp.has(entityID), "pet does not exist");

    return ownedComp.getValue(entityID);
  }

  // return owner or operator
  function isPetOwnerOrOperator(
    IUint256Component components,
    uint256 entityID,
    address sender
  ) internal view returns (bool) {
    if (getPetOwner(components, entityID) == sender) {
      // is owner
      return true;
    }

    address operator = OperatorComponent(
      getAddressById(components, OperatorComponentID)
    ).getValue(entityID);

    return operator==sender;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdOperatorComponent, ID as IdOpCompID } from "components/IdOperatorComponent.sol";
import { IdOwnerComponent, ID as IdOwnerCompID } from "components/IdOwnerComponent.sol";
import { IndexPetComponent, ID as IndexPetComponentID } from "components/IndexPetComponent.sol";
import { AddressComponent, ID as AddressCompID } from "components/AddressComponent.sol";
import { HashRateComponent, ID as HashRateCompID } from "components/HashRateComponent.sol";
import { MediaURIComponent, ID as MediaURICompID } from "components/MediaURIComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { StorageSizeComponent, ID as StorSizeCompID } from "components/StorageSizeComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";

library LibPet {
  // create a pet entity, set its owner and operator for an entity
  // NOTE: we may need to create an Operator/Owner entities here if they dont exist
  // TODO: include attributes in this generation
  function create(
    IWorld world,
    IUint256Component components,
    address owner,
    uint256 index
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, uint256(uint160(owner)));
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, uint256(uint160(owner)));
    IndexPetComponent(getAddressById(components, IndexPetComponentID)).set(id, index);
    return id;
  }

  // set a pet's stats from its attributes
  // TODO: update this to actually calculate the values
  function setStats(IUint256Component components, uint256 id) internal {
    HashRateComponent(getAddressById(components, HashRateCompID)).set(id, 0);
    StorageSizeComponent(getAddressById(components, StorSizeCompID)).set(id, 0);
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

  // get the name of this pet
  function getName(IUint256Component components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  function getMediaURI(IUint256Component components, uint256 id)
    internal
    view
    returns (string memory)
  {
    return MediaURIComponent(getAddressById(components, MediaURICompID)).getValue(id);
  }

  // get the entity ID of the pet operator
  function getOperator(IUint256Component components, uint256 id) internal view returns (uint256) {
    return IdOperatorComponent(getAddressById(components, IdOpCompID)).getValue(id);
  }

  // get the entity ID of the pet owner
  function getOwner(IUint256Component components, uint256 id) internal view returns (uint256) {
    return IdOwnerComponent(getAddressById(components, IdOwnerCompID)).getValue(id);
  }

  /////////////////
  // SETTERS

  function setOperator(
    IUint256Component components,
    uint256 id,
    uint256 operatorID
  ) internal {
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, operatorID);
  }

  function setOwner(
    IUint256Component components,
    uint256 id,
    uint256 ownerID
  ) internal {
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, ownerID);
  }

  /////////////////
  // OPERATORS
  function getOperator(
    IUint256Component components,
    uint256 entityID
  ) internal view returns (address) {
    return OperatorComponent(
      getAddressById(components, OperatorComponentID)
    ).getValue(entityID);
  }

  function changeOperator(
    IUint256Component components,
    uint256 entityID,
    address to
  ) internal {
   OperatorComponent(
      getAddressById(components, OperatorComponentID)
    ).set(entityID, to); 
  }


  /////////////////
  // QUERIES

  // get the entity ID of a pet from its index (tokenID)
  function indexToID(IUint256Component components, uint256 index)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = IndexPetComponent(getAddressById(components, IndexPetComponentID))
      .getEntitiesWithValue(index);
    if (results.length > 0) {
      result = results[0];
    }
  }

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

  // transfer ERC721 pet
  // NOTE/TODO: we need to be careful here about the flow on transferring pets
  // what needs to be updated? does an operator for the address exist?
  function transferPet(
    IUint256Component components,
    uint256 index,
    address to
  ) internal {
    // does not need to check for previous owner, ERC721 handles it
    uint256 id = indexToID(components, index);
    uint256 toID = uint256(uint160(to));
    setOwner(components, id, toID);
    setOperator(components, id, toID);
  }

  // return whether owner or operator
  // NOTE: is this function necessary?
  function isOwnerOrOperator(
    IUint256Component components,
    uint256 id,
    address sender
  ) internal view returns (bool) {
    uint256 senderAsID = uint256(uint160(sender));
    return getOwner(components, id) == senderAsID || getOperator(components, id) == senderAsID;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById, entityToAddress, addressToEntity } from "solecs/utils.sol";
import { LibString } from "solady/utils/LibString.sol";

import { IdOperatorComponent, ID as IdOpCompID } from "components/IdOperatorComponent.sol";
import { IdOwnerComponent, ID as IdOwnerCompID } from "components/IdOwnerComponent.sol";
import { IndexPetComponent, ID as IndexPetComponentID } from "components/IndexPetComponent.sol";
import { IsPetComponent, ID as IsPetCompID } from "components/IsPetComponent.sol";
import { HashRateComponent, ID as HashRateCompID } from "components/HashRateComponent.sol";
import { MediaURIComponent, ID as MediaURICompID } from "components/MediaURIComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { StorageSizeComponent, ID as StorSizeCompID } from "components/StorageSizeComponent.sol";
import { LibProduction } from "libraries/LibProduction.sol";

library LibPet {
  /////////////////
  // INTERACTIONS

  // create a pet entity, set its owner and operator for an entity
  // NOTE: we may need to create an Operator/Owner entities here if they dont exist
  // TODO: include attributes in this generation
  function create(
    IWorld world,
    IUintComp components,
    address owner,
    uint256 operatorID,
    uint256 index,
    string memory uri
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsPetComponent(getAddressById(components, IsPetCompID)).set(id);
    IndexPetComponent(getAddressById(components, IndexPetComponentID)).set(id, index);
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, addressToEntity(owner));
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, operatorID);
    MediaURIComponent(getAddressById(components, MediaURICompID)).set(id, uri);
    NameComponent(getAddressById(components, NameCompID)).set(
      id, LibString.concat("kamigotchi ", LibString.toString(index))
    );
    return id;
  }

  // set a pet's stats from its attributes
  // TODO: update this to actually calculate the values
  function setStats(IUintComp components, uint256 id) internal {
    HashRateComponent(getAddressById(components, HashRateCompID)).set(id, 11);
    StorageSizeComponent(getAddressById(components, StorSizeCompID)).set(id, 11);
  }

  /////////////////
  // CALCULATIONS

  // calculate and return the total storage size of a pet (including equipment)
  // TODO: include equipment
  function getTotalStorage(IUintComp components, uint256 id) internal view returns (uint256) {
    return StorageSizeComponent(getAddressById(components, StorSizeCompID)).getValue(id);
  }

  // calculate and return the total hash rate of a pet (including equipment)
  // TODO: include equipment
  function getTotalHashRate(IUintComp components, uint256 id) internal view returns (uint256) {
    return HashRateComponent(getAddressById(components, HashRateCompID)).getValue(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  // get the name of this pet
  function getName(IUintComp components, uint256 id) internal view returns (string memory) {
    return NameComponent(getAddressById(components, NameCompID)).getValue(id);
  }

  function getMediaURI(IUintComp components, uint256 id) internal view returns (string memory) {
    return MediaURIComponent(getAddressById(components, MediaURICompID)).getValue(id);
  }

  // get the entity ID of the pet operator
  function getOperator(IUintComp components, uint256 id) internal view returns (uint256) {
    return IdOperatorComponent(getAddressById(components, IdOpCompID)).getValue(id);
  }

  // get the entity ID of the pet owner
  function getOwner(IUintComp components, uint256 id) internal view returns (uint256) {
    return IdOwnerComponent(getAddressById(components, IdOwnerCompID)).getValue(id);
  }

  /////////////////
  // SETTERS

  function setOperator(
    IUintComp components,
    uint256 id,
    uint256 operatorID
  ) internal {
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, operatorID);
  }

  function setOwner(
    IUintComp components,
    uint256 id,
    uint256 ownerID
  ) internal {
    IdOwnerComponent(getAddressById(components, IdOwnerCompID)).set(id, ownerID);
  }

  /////////////////
  // QUERIES

  // get the entity ID of a pet from its index (tokenID)
  function indexToID(IUintComp components, uint256 index) internal view returns (uint256 result) {
    uint256[] memory results = IndexPetComponent(getAddressById(components, IndexPetComponentID))
      .getEntitiesWithValue(index);
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get the production of a pet. Return 0 if there are none.
  function getNodeProduction(
    IUintComp components,
    uint256 id,
    uint256 nodeID
  ) internal view returns (uint256 result) {
    uint256[] memory results = LibProduction._getAllX(components, nodeID, id, "");
    if (results.length > 0) {
      result = results[0];
    }
  }

  // Get the production of a pet. Return 0 if there are none.
  // We can assume pets can only commit to one active production.
  function getActiveProduction(IUintComp components, uint256 id)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = LibProduction._getAllX(components, 0, id, "ACTIVE");
    if (results.length > 0) {
      result = results[0];
    }
  }

  /////////////////
  // ERC721

  // transfer ERC721 pet
  // NOTE: it doesnt seem we actually need IdOwner directly on the pet as it can be
  // directly accessed through the operator entity.
  function transfer(
    IUintComp components,
    uint256 index,
    uint256 operatorID
  ) internal {
    // does not need to check for previous owner, ERC721 handles it
    uint256 id = indexToID(components, index);
    uint256 ownerID = getOwner(components, operatorID);

    setOwner(components, id, ownerID);
    setOperator(components, id, operatorID);
  }

  // return whether owner or operator
  function isOwnerOrOperator(
    IUintComp components,
    uint256 id,
    address sender
  ) internal view returns (bool) {
    uint256 senderAsID = addressToEntity(sender);
    return getOwner(components, id) == senderAsID || getOperator(components, id) == senderAsID;
  }
}

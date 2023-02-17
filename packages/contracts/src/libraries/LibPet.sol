// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibString } from "solady/utils/LibString.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById, getComponentById, entityToAddress, addressToEntity } from "solecs/utils.sol";

import { IdOperatorComponent, ID as IdOpCompID } from "components/IdOperatorComponent.sol";
import { IdOwnerComponent, ID as IdOwnerCompID } from "components/IdOwnerComponent.sol";
import { IndexPetComponent, ID as IndexPetComponentID } from "components/IndexPetComponent.sol";
import { IsPetComponent, ID as IsPetCompID } from "components/IsPetComponent.sol";
import { BandwidthComponent, ID as BandwidthCompID } from "components/BandwidthComponent.sol";
import { CapacityComponent, ID as CapacityCompID } from "components/CapacityComponent.sol";
import { ChargeComponent, ID as ChargeCompID } from "components/ChargeComponent.sol";
import { MediaURIComponent, ID as MediaURICompID } from "components/MediaURIComponent.sol";
import { NameComponent, ID as NameCompID } from "components/NameComponent.sol";
import { StorageSizeComponent, ID as StorSizeCompID } from "components/StorageSizeComponent.sol";
import { TimeLastActionComponent, ID as TimeLastCompID } from "components/TimeLastActionComponent.sol";
import { PetTraitsPermanentComponent, ID as TraitsCompID } from "components/PetTraitsPermanentComponent.sol";
import { LibModifier } from "libraries/LibModifier.sol";
import { LibProduction } from "libraries/LibProduction.sol";

uint256 constant BASE_CAPACITY = 150;
uint256 constant BASE_BANDWIDTH = 150;
uint256 constant BASE_STORAGE = 500;
uint256 constant CHARGE_EPOCH = 600; // 10min

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
    TimeLastActionComponent(getAddressById(components, TimeLastCompID)).set(id, block.timestamp);

    string memory name = LibString.concat("kamigotchi ", LibString.toString(index));
    NameComponent(getAddressById(components, NameCompID)).set(id, name);

    return id;
  }

  // update the battery charge of a pet based on its timestamp and charge at last action.
  // NOTE: if the returned charge is 0 we should make sure the pet dies
  // NOTE: should be called at the top of a System and folllowed up with a require(!isDead)
  function updateCharge(IUintComp components, uint256 id) internal returns (uint256 newCharge) {
    uint256 lastTs = getLastTs(components, id);
    uint256 duration = block.timestamp - lastTs;
    uint256 drain = (duration + CHARGE_EPOCH - 1) / CHARGE_EPOCH; // round up to get
    uint256 prevCharge = getCharge(components, id);

    newCharge = (prevCharge > drain) ? prevCharge - drain : 0;
    setCharge(components, id, newCharge);
  }

  /////////////////
  // SETTERS

  // set a pet's stats from its traits
  // TODO: actually set stats from traits. hardcoded currently
  function setStats(IUintComp components, uint256 id) internal {
    BandwidthComponent(getAddressById(components, BandwidthCompID)).set(id, BASE_BANDWIDTH);
    StorageSizeComponent(getAddressById(components, StorSizeCompID)).set(id, BASE_STORAGE);

    uint256 totalCapacity = BASE_CAPACITY;
    CapacityComponent(getAddressById(components, CapacityCompID)).set(id, totalCapacity);
    ChargeComponent(getAddressById(components, ChargeCompID)).set(id, totalCapacity);
  }

  function setCharge(
    IUintComp components,
    uint256 id,
    uint256 charge
  ) internal {
    ChargeComponent(getAddressById(components, ChargeCompID)).set(id, charge);
  }

  function setName(
    IUintComp components,
    uint256 id,
    string memory name
  ) internal {
    NameComponent(getAddressById(components, NameCompID)).set(id, name);
  }

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
  // CHECKS

  function isPet(IUintComp components, uint256 id) internal view returns (bool) {
    return IsPetComponent(getAddressById(components, IsPetCompID)).has(id);
  }

  function isDead(IUintComp components, uint256 id) internal view returns (bool) {
    return getCharge(components, id) == 0;
  }

  // Check whether a pet has an ongoing production.
  function isProducing(IUintComp components, uint256 id) internal view returns (bool result) {
    uint256[] memory results = LibProduction._getAllX(components, 0, id, "ACTIVE");
    if (results.length > 0) {
      result = true;
    }
  }

  /////////////////
  // CALCULATIONS

  // calculate and return the total storage size of a pet (including equipment)
  // TODO: include equipment stats
  function getTotalStorage(IUintComp components, uint256 id) internal view returns (uint256) {
    return StorageSizeComponent(getAddressById(components, StorSizeCompID)).getValue(id);
  }

  // calculate and return the total bandwidth of a pet (including equipment)
  // TODO: include equipment stats
  // TODO: update this to bandwidth, soon:tm:
  function getTotalBandwidth(IUintComp components, uint256 id) internal view returns (uint256) {
    return BandwidthComponent(getAddressById(components, BandwidthCompID)).getValue(id);
  }

  // calculate and return the total battery capacity of a pet (including equipment)
  // TODO: include equipment stats
  function getTotalCapacity(IUintComp components, uint256 id) internal view returns (uint256) {
    return BandwidthComponent(getAddressById(components, BandwidthCompID)).getValue(id);
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getCharge(IUintComp components, uint256 id) internal view returns (uint256) {
    return ChargeComponent(getAddressById(components, ChargeCompID)).getValue(id);
  }

  function getLastTs(IUintComp components, uint256 id) internal view returns (uint256) {
    return TimeLastActionComponent(getAddressById(components, TimeLastCompID)).getValue(id);
  }

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
  function getProduction(IUintComp components, uint256 id) internal view returns (uint256 result) {
    uint256[] memory results = LibProduction._getAllX(components, 0, id, "");
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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import { IUint256Component as IUintComp } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { IdOperatorComponent, ID as IdOpCompID } from "components/IdOperatorComponent.sol";
import { IdNodeComponent, ID as IdNodeCompID } from "components/IdNodeComponent.sol";
import { IdPetComponent, ID as IdPetCompID } from "components/IdPetComponent.sol";
import { IsProductionComponent, ID as IsProdCompID } from "components/IsProductionComponent.sol";
import { StateComponent, ID as StateCompID } from "components/StateComponent.sol";
import { TimeStartComponent, ID as TimeStartCompID } from "components/TimeStartComponent.sol";
import { LibCoin } from "libraries/LibCoin.sol";
import { LibPet } from "libraries/LibPet.sol";
import { Strings } from "utils/Strings.sol";

/*
 * LibNode handles all retrieval and manipulation of mining nodes/productions
 */
library LibProduction {
  // Creates a production for a character at a deposit. Assumes one doesn't already exist.
  function create(
    IWorld world,
    IUintComp components,
    uint256 nodeID,
    uint256 operatorID,
    uint256 petID
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsProductionComponent(getAddressById(components, IsProdCompID)).set(id);
    IdNodeComponent(getAddressById(components, IdNodeCompID)).set(id, nodeID);
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, operatorID);
    IdPetComponent(getAddressById(components, IdPetCompID)).set(id, petID);
    StateComponent(getAddressById(components, StateCompID)).set(id, string("ACTIVE"));
    TimeStartComponent(getAddressById(components, TimeStartCompID)).set(id, block.timestamp);
    return id;
  }

  // Resets the starting block of a production to the current block
  function reset(IUintComp components, uint256 id) internal {
    TimeStartComponent(getAddressById(components, TimeStartCompID)).set(id, block.timestamp);
  }

  // Starts an _existing_ production if not already started. Update the owning character as needed.
  function start(IUintComp components, uint256 id) internal {
    uint256 ownerID = IdOperatorComponent(getAddressById(components, IdOpCompID)).getValue(id);
    IdOperatorComponent(getAddressById(components, IdOpCompID)).set(id, ownerID);

    StateComponent StateC = StateComponent(getAddressById(components, StateCompID));
    if (!StateC.hasValue(id, "ACTIVE")) {
      reset(components, id);
      StateC.set(id, string("ACTIVE"));
    }
  }

  // Stops an _existing_ production. All potential proceeds will be lost after this point.
  function stop(IUintComp components, uint256 id) internal {
    StateComponent StateC = StateComponent(getAddressById(components, StateCompID));
    if (!StateC.hasValue(id, "INACTIVE")) {
      StateC.set(id, string("INACTIVE"));
    }
  }

  /////////////////////
  // CALCULATIONS

  // Calculate the reward from an ACTIVE production using equipment and attributes.
  function calc(IUintComp components, uint256 id) internal view returns (uint256) {
    uint256 petID = IdPetComponent(getAddressById(components, IdPetCompID)).getValue(id);

    if (!StateComponent(getAddressById(components, StateCompID)).hasValue(id, "ACTIVE")) {
      return 0;
    }

    // TODO: update this to include other multipliers once we have theming of that
    uint256 hashRate = LibPet.getTotalHashRate(components, petID);
    uint256 storageSize = LibPet.getTotalStorage(components, petID);
    uint256 duration = getDuration(components, id);
    uint256 output = hashRate * duration;
    if (output > storageSize) output = storageSize;
    return output;
  }

  // Get the duration since TimeStart of a production
  function getDuration(IUintComp components, uint256 id) internal view returns (uint256) {
    uint256 startTime = TimeStartComponent(getAddressById(components, TimeStartCompID)).getValue(
      id
    );
    return block.timestamp - startTime;
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getNode(IUintComp components, uint256 id) internal view returns (uint256) {
    return IdNodeComponent(getAddressById(components, IdNodeCompID)).getValue(id);
  }

  function getOperator(IUintComp components, uint256 id) internal view returns (uint256) {
    return IdOperatorComponent(getAddressById(components, IdOpCompID)).getValue(id);
  }

  function getPet(IUintComp components, uint256 id) internal view returns (uint256) {
    return IdPetComponent(getAddressById(components, IdPetCompID)).getValue(id);
  }

  function getState(IUintComp components, uint256 id) internal view returns (string memory) {
    return StateComponent(getAddressById(components, StateCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // Retrieves all active productions of a character
  function getAllActiveForCharacter(IUintComp components, uint256 operatorID)
    internal
    view
    returns (uint256[] memory)
  {
    return _getAllX(components, 0, operatorID, 0, "ACTIVE");
  }

  // Retrieves all productions based on any defined filters
  function _getAllX(
    IUintComp components,
    uint256 nodeID,
    uint256 operatorID,
    uint256 petID,
    string memory state
  ) internal view returns (uint256[] memory) {
    uint256 numFilters;
    if (nodeID != 0) numFilters++;
    if (operatorID != 0) numFilters++;
    if (petID != 0) numFilters++;
    if (!Strings.equal(state, "")) numFilters++;

    QueryFragment[] memory fragments = new QueryFragment[](numFilters + 1);
    fragments[0] = QueryFragment(QueryType.Has, getComponentById(components, IsProdCompID), "");

    uint256 filterCount;
    if (nodeID != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdNodeCompID),
        abi.encode(nodeID)
      );
    }
    if (operatorID != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdOpCompID),
        abi.encode(operatorID)
      );
    }
    if (petID != 0) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, IdPetCompID),
        abi.encode(petID)
      );
    }
    if (!Strings.equal(state, "")) {
      fragments[++filterCount] = QueryFragment(
        QueryType.HasValue,
        getComponentById(components, StateCompID),
        abi.encode(state)
      );
    }

    return LibQuery.query(fragments);
  }
}

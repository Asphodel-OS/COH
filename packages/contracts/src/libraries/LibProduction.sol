// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import { IUint256Component as IComponents } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { QueryFragment, QueryType } from "solecs/interfaces/Query.sol";
import { LibQuery } from "solecs/LibQuery.sol";
import { getAddressById, getComponentById } from "solecs/utils.sol";

import { ID as IdOpCompID } from "components/IdOperatorComponent.sol";
import { IdNodeComponent, ID as IdNodeCompID } from "components/IdNodeComponent.sol";
import { IdPetComponent, ID as IdPetCompID } from "components/IdPetComponent.sol";
import { IsProductionComponent, ID as IsProdCompID } from "components/IsProductionComponent.sol";
import { StateComponent, ID as StateCompID } from "components/StateComponent.sol";
import { TimeStartComponent, ID as TimeStartCompID } from "components/TimeStartComponent.sol";
import { LibPet } from "libraries/LibPet.sol";
import { Strings } from "utils/Strings.sol";

/*
 * LibProduction handles all retrieval and manipulation of mining nodes/productions
 */
library LibProduction {
  /////////////////////
  // INTERACTIONS

  // Creates a production for a pet at a deposit. Assumes one doesn't already exist.
  function create(
    IWorld world,
    IComponents components,
    uint256 nodeID,
    uint256 petID
  ) internal returns (uint256) {
    uint256 id = world.getUniqueEntityId();
    IsProductionComponent(getAddressById(components, IsProdCompID)).set(id);
    IdNodeComponent(getAddressById(components, IdNodeCompID)).set(id, nodeID);
    IdPetComponent(getAddressById(components, IdPetCompID)).set(id, petID);
    StateComponent(getAddressById(components, StateCompID)).set(id, string("ACTIVE"));
    TimeStartComponent(getAddressById(components, TimeStartCompID)).set(id, block.timestamp);
    return id;
  }

  // Resets the starting block of a production to the current block
  function reset(IComponents components, uint256 id) internal {
    TimeStartComponent(getAddressById(components, TimeStartCompID)).set(id, block.timestamp);
  }

  // Starts an _existing_ production if not already started. Update the owning character as needed.
  function start(IComponents components, uint256 id) internal {
    StateComponent StateC = StateComponent(getAddressById(components, StateCompID));
    if (!StateC.hasValue(id, "ACTIVE")) {
      reset(components, id);
      StateC.set(id, string("ACTIVE"));
    }
  }

  // Stops an _existing_ production. All potential proceeds will be lost after this point.
  function stop(IComponents components, uint256 id) internal {
    StateComponent StateC = StateComponent(getAddressById(components, StateCompID));
    if (!StateC.hasValue(id, "INACTIVE")) {
      StateC.set(id, string("INACTIVE"));
    }
  }

  // set the node of a production
  function setNode(
    IComponents components,
    uint256 id,
    uint256 nodeID
  ) internal {
    IdNodeComponent NodeC = IdNodeComponent(getAddressById(components, IdNodeCompID));
    if (NodeC.getValue(id) != nodeID) {
      NodeC.set(id, nodeID);
    }
  }

  /////////////////////
  // CALCULATIONS

  // Calculate the reward from an ACTIVE production using equipment and attributes.
  function calc(IComponents components, uint256 id) internal view returns (uint256) {
    uint256 petID = IdPetComponent(getAddressById(components, IdPetCompID)).getValue(id);

    if (!StateComponent(getAddressById(components, StateCompID)).hasValue(id, "ACTIVE")) {
      return 0;
    }

    // TODO: update this to include other multipliers once we have theming of that
    uint256 bandwidth = LibPet.getTotalBandwidth(components, petID);
    uint256 storageSize = LibPet.getTotalStorage(components, petID);
    uint256 duration = getDuration(components, id);
    uint256 output = bandwidth * duration;
    if (output > storageSize) output = storageSize;
    return output;
  }

  // Get the duration since TimeStart of a production
  function getDuration(IComponents components, uint256 id) internal view returns (uint256) {
    uint256 startTime = TimeStartComponent(getAddressById(components, TimeStartCompID)).getValue(
      id
    );
    return block.timestamp - startTime;
  }

  /////////////////
  // COMPONENT RETRIEVAL

  function getNode(IComponents components, uint256 id) internal view returns (uint256) {
    return IdNodeComponent(getAddressById(components, IdNodeCompID)).getValue(id);
  }

  function getPet(IComponents components, uint256 id) internal view returns (uint256) {
    return IdPetComponent(getAddressById(components, IdPetCompID)).getValue(id);
  }

  /////////////////
  // QUERIES

  // get an active production of a pet. assumed 1 at most
  function getActiveForPet(IComponents components, uint256 petID)
    internal
    view
    returns (uint256 result)
  {
    uint256[] memory results = _getAllX(components, 0, petID, "ACTIVE");
    if (results.length != 0) {
      result = results[0];
    }
  }

  // get a production by a pet. assumed only 1
  function getForPet(IComponents components, uint256 petID) internal view returns (uint256 result) {
    uint256[] memory results = _getAllX(components, 0, petID, "");
    if (results.length != 0) {
      result = results[0];
    }
  }

  // Retrieves all productions based on any defined filters
  function _getAllX(
    IComponents components,
    uint256 nodeID,
    uint256 petID,
    string memory state
  ) internal view returns (uint256[] memory) {
    uint256 numFilters;
    if (nodeID != 0) numFilters++;
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

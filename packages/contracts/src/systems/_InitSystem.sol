// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibBattery } from "libraries/LibBattery.sol";
import { LibInventory } from "libraries/LibInventory.sol";
import { LibModifier } from "libraries/LibModifier.sol";
import { Utils } from "utils/Utils.sol";

import { ID as PetSysID } from "systems/ERC721PetSystem.sol";

uint256 constant ID = uint256(keccak256("system._Init"));

// admin only system to _init everything
contract _InitSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    arguments = "";

    initFood();
    initMods();
    
    // for erc721 pet
    LibInventory._set(components, PetSysID, 0);

    return "";
  }

  function executeTyped() public onlyOwner returns (bytes memory) {
    return execute(abi.encode(new bytes(0)));
  }

  function initFood() internal {
    LibBattery.addFoodRegistry(components, world, 100001, 25, "food 1");
    LibBattery.addFoodRegistry(components, world, 100002, 100, "food 2");
    LibBattery.addFoodRegistry(components, world, 100003, 200, "food 3");
  }

  function initMods() internal {

    LibModifier.createIndex(
      components,
      world,
      "BODY",
      1, // index
      1, // mod value
      "MUL",
      "Butterfly"
    );
    LibModifier.createIndex(
      components,
      world,
      "BODY",
      2, // index
      2, // mod value
      "MUL",
      "Cube"
    );

    LibModifier.createIndex(
      components,
      world,
      "COLOR",
      1, // index
      1, // mod value
      "ADD",
      "Canto Green"
    );

    LibModifier.createIndex(
      components,
      world,
      "FACE",
      1, // index
      1, // mod value
      "UMUL",
      "c-c"
    );
    LibModifier.createIndex(
      components,
      world,
      "FACE",
      2, // index
      2, // mod value
      "UMUL",
      "uwu"
    );

    LibModifier.createIndex(
      components,
      world,
      "HAND",
      1, // index
      1, // mod value
      "STORAGE",
      "Slicers"
    );
    LibModifier.createIndex(
      components,
      world,
      "HAND",
      2, // index
      2, // mod value
      "STORAGE",
      "Paws"
    );

    LibModifier.createIndex(
      components,
      world,
      "BACKGROUND",
      1, // index
      1, // mod value
      "UMUL",
      "background1"
    );
  }
}

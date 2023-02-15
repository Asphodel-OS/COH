// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibBattery } from "libraries/LibBattery.sol";
import { LibInventory } from "libraries/LibInventory.sol";
import { LibPet } from "libraries/LibPet.sol";
import { Utils } from "utils/Utils.sol";

uint256 constant ID = uint256(keccak256("system.Pet.Food"));

// eat one snack
contract PetFoodSystem is System {
  constructor(IWorld _world, address _components)
    System(_world, _components)
  {}

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    (uint256 petID, uint256 food) = abi.decode(arguments, (uint256, uint256));
    
    uint256 operatorID = LibOperator.getByAddress(components, msg.sender);
    require(LibPet.getOperator(components, petID) == operatorID, "Pet: not urs");
    
    uint256 invID = LibInventory.get(components, operatorID, food);
    require(
      invID != 0 && LibInventory.getBalance(components, invID) != 0,
      "no food"
    );

    // eat 1 food item
    LibInventory.dec(components, invID, 1);
    LibBattery.chargeBat(
      components, 
      petID, 
      LibBattery.getFoodValue(components, food)
    );

    return "";
  }

  function executeTyped(
    uint256 petID,
    uint256 food
  ) public onlyOwner returns (bytes memory) {
    return execute(abi.encode(petID, food));
  }

}
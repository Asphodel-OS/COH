// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { System } from "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";

import { LibMerchant } from "libraries/LibMerchant.sol";

uint256 constant ID = uint256(keccak256("system.MerchantCreate"));

// MerchantCreateSystem creates or updates a merchant listing from the provided parameters
contract MerchantCreateSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory arguments) public onlyOwner returns (bytes memory) {
    (uint256 location, string memory name) = abi.decode(arguments, (uint256, string));

    return abi.encode(LibMerchant.createMerchant(world, components, location, name));
  }

  function executeTyped(uint256 location, string memory name)
    public
    onlyOwner
    returns (bytes memory)
  {
    return execute(abi.encode(location, name));
  }
}

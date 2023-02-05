// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/BoolComponent.sol";

uint256 constant ID = uint256(keccak256("component.Is.RegistryEntry"));

// identifies an entity as a registry entry
contract IsRegistryEntryComponent is BoolComponent {
  constructor(address world) BoolComponent(world, ID) {}
}

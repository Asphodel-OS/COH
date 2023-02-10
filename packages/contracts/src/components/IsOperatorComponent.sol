// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/BoolComponent.sol";

uint256 constant ID = uint256(keccak256("component.Is.Operator"));

// identifies an entity as a Operator
contract IsOperatorComponent is BoolComponent {
  constructor(address world) BoolComponent(world, ID) {}
}

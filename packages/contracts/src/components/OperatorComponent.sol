// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/AddressComponent.sol";

uint256 constant ID = uint256(keccak256("component.Operator"));

// the operating wallet address of a character
contract OperatorComponent is AddressComponent {
  constructor(address world) AddressComponent(world, ID) {}
}

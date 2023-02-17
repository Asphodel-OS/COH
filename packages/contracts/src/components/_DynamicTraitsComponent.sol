// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256ArrayBareComponent.sol";

uint256 constant ID = uint256(keccak256("component.PetTraits._Dynamic"));

// implementating proper trait entities is not fully implmented yet
// this component is to demonstrate the dyanmic metadata on FE
contract _DynamicTraitsComponent is Uint256ArrayBareComponent {
  constructor(address world) Uint256ArrayBareComponent(world, ID) {}
}

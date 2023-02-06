// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/AddressComponent.sol";

uint256 constant ID = uint256(keccak256("component.ERC721.OwnedBy.Pet"));

// Address that owns the ERC721
contract ERC721OwnedByPetComponent is AddressComponent {
  constructor(address world) AddressComponent(world, ID) {}
}
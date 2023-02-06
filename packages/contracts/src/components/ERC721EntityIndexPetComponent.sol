// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.ERC721.EntityIndex.Pet"));

// Map component from entityID to the pet's ERC721 id
contract ERC721EntityIndexPetComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}

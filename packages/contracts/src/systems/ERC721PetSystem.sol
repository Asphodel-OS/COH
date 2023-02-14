// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { System } from "solecs/System.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibOperator } from "libraries/LibOperator.sol";
import { LibPet } from "libraries/LibPet.sol";
import { LibPetTraits } from "libraries/LibPetTraits.sol";

import { PetMetadataSystem, ID as PetMetadataSystemID } from "systems/PetMetadataSystem.sol";

uint256 constant ID = uint256(keccak256("system.ERC721.pet"));
string constant NFT_NAME = "Kamigotchi";
string constant NFT_SYMBOL = "KAMI";
// unrevealed URI is set as the placeholder. actual random implementation unimplemented for demo, no proper vrf on localhost
string constant UNREVEALED_URI = "https://kamigotchi.nyc3.cdn.digitaloceanspaces.com/placeholder.gif";

contract ERC721PetSystem is System, ERC721 {
  /*******************************
   *         Mint Details
   ********************************/
  uint256 public totalSupply;

  constructor(IWorld _world, address _components)
    System(_world, _components)
    ERC721(NFT_NAME, NFT_SYMBOL)
  {}

  // temporary init function to prevent circular dependency
  bool inited;
  function init() public {
    if(!inited) {
      LibPetTraits.placeholderRegistry(components, world);
      inited = true;
    }
  }

  /*********************
   *  Public Functions
   **********************/

  function mint(address to) public returns (uint256) {
    // require(tx.origin == msg.sender, "no contracts");
    ++totalSupply; // arrays start at 1 here :3

    // Get the operator for this owner(to). Create one if it doesn't exist.
    uint256 operatorID = LibOperator.getByOwner(components, to);
    if (operatorID == 0) {
      operatorID = LibOperator.create(world, components, to, to);
    }

    // TODO: set stats based on the generated traits of the pet.
    uint256 petID = LibPet.create(world, components, to, operatorID, totalSupply, UNREVEALED_URI);
    LibPetTraits.placeholderTraits(components, world, petID);
    // LibPet.setStats(components, petID);

    _mint(to, totalSupply); // should we run this at the beginning or end?
    return petID;
  }

  function tokenURI(uint256 tokenID) public view override returns (string memory) {
    return PetMetadataSystem(
      getAddressById(world.systems(), PetMetadataSystemID)
    ).tokenURI(tokenID);
  }

  /*********************
   *     MUD Hoppers
   **********************/
  function tokenIDToEntityID(uint256 petIndex) public view returns (uint256) {
    return LibPet.indexToID(components, petIndex);
  }

  // NOTE: the id here is actually the ERC721 id, aka the pet index in our world
  function transferFrom(
    address from,
    address to,
    uint256 id
  ) public virtual override {
    // Get the operator for the new owner(to). Create one if it doesn't exist.
    uint256 operatorID = LibOperator.getByOwner(components, to);
    if (operatorID == 0) {
      operatorID = LibOperator.create(world, components, to, to);
    }

    // ownership checks and updates should keep us safe from the ERC721 side
    LibPet.transfer(components, id, operatorID);
    super.transferFrom(from, to, id);
  }

  // required for MUD, not in use
  function execute(bytes memory arguments) public pure returns (bytes memory) {
    require(false, "execute not available");
    arguments = "";
    return "";
  }

  function executeTyped(address ownerAddy) public pure returns (bytes memory) {
    return execute(abi.encode(ownerAddy));
  }
}

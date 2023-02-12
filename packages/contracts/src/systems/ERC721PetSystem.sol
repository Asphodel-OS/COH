// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { System } from "solecs/System.sol";
import { ERC721 } from "solmate/tokens/ERC721.sol";

import { LibPet } from "libraries/LibPet.sol";
import { LibPetTraits } from "libraries/LibPetTraits.sol";

uint256 constant ID = uint256(keccak256("system.ERC721.pet"));
string constant NFT_NAME = "Kamigotchi";
string constant NFT_SYMBOL = "KAMI";

contract ERC721PetSystem is System, ERC721 {
  /*******************************
   *         Mint Details
   ********************************/
  uint256 public totalSupply;

  constructor(IWorld _world, address _components)
    System(_world, _components)
    ERC721(NFT_NAME, NFT_SYMBOL)
  {}

  /*********************
   *  Public Functions
   **********************/

  function mint(address to) public returns (uint256) {
    // require(tx.origin == msg.sender, "no contracts");
    
    // TODO: PLACEHOLDER, replace later
    string memory uri = "https://kamigotchi.nyc3.cdn.digitaloceanspaces.com/placeholder.png";
    uint256 entityID = LibPet.create(components, world, to, totalSupply, uri);


    LibPet.setStats(components, entityID);

    LibPetTraits.placeholderRegistry(components, world);
    LibPetTraits.placeholderTraits(components, world, entityID);

    _mint(to, totalSupply);
    totalSupply++;
    return entityID;
  }

  function tokenURI(uint256 tokenID) public view override returns (string memory) {
    uint256 petID = LibPet.indexToID(components, tokenID);
    return LibPet.getMediaURI(components, petID);
  }

  /*********************
   *     MUD Hoppers
   **********************/
  // NOTE: do we need this?
  function tokenIDToEntityID(uint256 petIndex) public view returns (uint256) {
    return LibPet.indexToID(components, petIndex);
  }

  function transferFrom(
    address from,
    address to,
    uint256 id
  ) public virtual override {
    LibPet.transferPet(components, id, to);

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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IComponent } from "solecs/interfaces/IComponent.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";

import { ERC721 } from "solmate/tokens/ERC721.sol";

import { LibPet } from "libraries/LibPet.sol";

import { ERC721OwnedByPetComponent, ID as ERC721OwnedByPetComponentID } from "components/ERC721OwnedByPetComponent.sol";
import { ERC721EntityIndexPetComponent, ID as ERC721EntityIndexPetComponentID } from "components/ERC721EntityIndexPetComponent.sol";
import { MediaURIComponent, ID as MediaURIComponentID } from "components/MediaURIComponent.sol";

uint256 constant ID = uint256(keccak256("system.ERC721.pet"));

string constant NFT_NAME = "Petaruchi";
string constant NFT_SYMBOL = "PET";

contract ERC721PetSystem is System, ERC721 {

  /*******************************
  *         Mint Details
  ********************************/
  uint256 public totalSupply;

  constructor(
    IWorld _world,
    address _components
  ) System(_world, _components) ERC721(NFT_NAME, NFT_SYMBOL) {

  }

  /*********************
  *  Public Functions 
  **********************/

  function mint(address to) public returns (uint256) {
    // require(tx.origin == msg.sender, "no contracts");

    uint256 entityID = LibPet.create(
      components, 
      world, 
      totalSupply, 
      to,
      1, // hashrate
      1  // storage size
    );

    // set metadata component
    //  here!

    _mint(to, totalSupply);

    totalSupply++;
    
    return entityID;
  }

  function tokenURI(uint256 tokenID) public view override returns (string memory) {
    uint256 entityID = nftToEntityID(tokenID);

    return MediaURIComponent(
      getAddressById(components, MediaURIComponentID)
    ).getValue(entityID);
  }

  /*********************
  *     MUD Hoppers  
  **********************/
  function nftToEntityID(uint256 tokenID) public view returns (uint256) {
    return LibPet.nftToEntityID(components, tokenID);
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 id
  ) public virtual override {
    LibPet.transferPet(components, id, to);
    
    super.transferFrom(from, to, id);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id
  ) public virtual override {
    LibPet.transferPet(components, id, to);

    super.safeTransferFrom(from, to, id);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id, 
    bytes calldata data
  ) public virtual override {
    LibPet.transferPet(components, id, to);

    super.safeTransferFrom(from, to, id, data);
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

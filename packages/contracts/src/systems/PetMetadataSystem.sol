// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { System } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { LibString } from "solady/utils/LibString.sol";

import { LibPet } from "libraries/LibPet.sol";
import { LibPetTraits } from "libraries/LibPetTraits.sol";

import { ID as PetSystemID } from "systems/ERC721PetSystem.sol";

uint256 constant ID = uint256(keccak256("system.ERC721.metadata"));

contract PetMetadataSystem is System {
  constructor(IWorld _world, address _components)
    System(_world, _components)
  {}

  /*********************
   *  PET SET PIC
  **********************/

  modifier onlyPetSystem() {
    require(
      msg.sender == getAddressById(components, PetSystemID),
      "not Pet System"
    );
    _;
  }

  function execute(bytes memory arguments) public onlyPetSystem returns (bytes memory) {
    require(false, "execute not available");
    arguments = "";
    return "";
  }

  function executeTyped(address ownerAddy) public onlyPetSystem returns (bytes memory) {
    return execute(abi.encode(ownerAddy));
  }

  /*********************
   *  METADATA ASSEMBLER
  **********************/

        //     "{",
        // //\"external_url\": \"https://asphodel.xyz\",",
        // 
        // "\"image\": \"", baseURI, imageId.toString(),  ".svg\",",
        // "\"name\": "\"NAME\","
        // "\"description\": "\"Kamigotchi\",", 
        // //"\"attributes\": [",
        // //"{\"trait_type\": \"Vigor\", \"value\": \"", vigor.toString(), "\",}",
        // //"{\"trait_type\": \"Mind\", \"value\": \"", mind.toString(), "\"},",
        // //"{\"trait_type\": \"Guile\", \"value\": \"", guile.toString(), "\"}",
        // //"]",
        // "}" 

  function tokenURI(uint256 tokenID) public view returns (string memory) {
    uint256 petID = LibPet.indexToID(components, tokenID);
    // return LibPet.getMediaURI(components, petID);
    return _getBaseTraits(petID);
  }

  function _getBaseTraits(uint256 entityID) public view returns (string memory) {
    string memory result = "";

    // getting values of base traits. values are hardcoded to array position
    string[] memory names = new string[](6);
    string[] memory values = LibPetTraits.getNames(
      components, LibPetTraits.getPermArray(components, entityID)
    );

    for (uint256 i; i < names.length; i++) {
      // string memory entry = LibString.concat(
      //   '{\"trait_type\": \" ',
      //   names[i]
      // );
      // entry = LibString.concat(
      //   '
      // )
      string memory entry = string(abi.encodePacked(
        '{"trait_type": "', 
        names[i], 
        '", "value": ",',
        values[i], 
        '}'
      ));

      result = string(abi.encodePacked(result, entry));
    }

    return result;
  }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "test/utils/SetupTemplate.s.sol";

contract ERC721PetTest is SetupTemplate {
  function _assertOwnership(uint256 tokenID, address addy) internal {
    // owner and component must be the same
    uint256 entityID = LibPet.indexToID(components, tokenID);
    assertEq(
      _ERC721PetSystem.ownerOf(tokenID),
      entityToAddress(_IdOwnerComponent.getValue(entityID))
    );
    assertEq(_ERC721PetSystem.ownerOf(tokenID), addy);
  }

  function _assertOperator(uint256 entityID, address operator) internal {
    // assertEq(_IdOperatorComponent.getValue(entityID), addressToEntity(operator));
  }

  function entityToAddress(uint256 entityID) internal returns (address) {
    return address(uint160(entityID));
  }

  function testMint() public {
    _mintPets(1);

    _assertOwnership(1, alice);
    _assertOperator(petOneEntityID, alice);
  }

  function testTransfer() public {
    _mintPets(1);

    _transferPetNFT(alice, bob, 1);

    _assertOwnership(1, bob);
    _assertOperator(petOneEntityID, bob);
  }

  function testSafeTransfer() public {
    _mintPets(1);

    vm.prank(alice);
    _ERC721PetSystem.safeTransferFrom(alice, bob, 1);

    _assertOwnership(1, bob);
    _assertOperator(petOneEntityID, bob);

    vm.prank(bob);
    _ERC721PetSystem.safeTransferFrom(bob, eve, 1, "");

    _assertOwnership(1, eve);
    _assertOperator(petOneEntityID, eve);
  }

  function testChangeOperator() public {
    _mintPets(1);

    vm.prank(alice);
    _PetSetOperatorSystem.executeTyped(petOneEntityID, bob);

    _assertOwnership(1, alice);
    _assertOperator(petOneEntityID, bob);
  }

  function testMetadataPrint() public {
    _mintPets(1);

    console.log(
      _ERC721PetSystem.tokenURI(1)
    );
  }

  function testMetadataFuzz() public {
    // maybe shouldnt loop..
    uint256 max = 99;
    for (uint256 i; i < max; i++) {
      _mintSinglePet(address(1));
    }
  }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "test/utils/SetupTemplate.s.sol";

contract ERC721PetTest is SetupTemplate {
  function _assertOwnership(
    uint256 tokenID,
    address addy
  ) internal {
    // owner and component must be the same
    uint256 entityID = LibPet.indexToID(components, tokenID);
    assertEq(
      _ERC721PetSystem.ownerOf(tokenID),
      entityToAddress(_IdOwnerComponent.getValue(entityID))
    );
    assertEq(
      _ERC721PetSystem.ownerOf(tokenID),
      addy
    );
  }

  function _assertOperator(
    uint256 entityID,
    address operator
  ) internal {
    assertEq(
      _IdOperatorComponent.getValue(entityID),
      addressToEntity(operator)
    );
  }

  function testMint() public {
    _mintPets(1);

    _assertOwnership(0, alice);
    _assertOperator(petOneEntityID, alice);    
  }

  function testTransfer() public {
    _mintPets(1);

    _transferPetNFT(alice, bob, 0);

    _assertOwnership(0, bob);
    _assertOperator(petOneEntityID, bob);
  }

  function testSafeTransfer() public {
    _mintPets(1);

    vm.prank(alice);
    _ERC721PetSystem.safeTransferFrom(alice, bob, 0);

    _assertOwnership(0, bob);
    _assertOperator(petOneEntityID, bob);

    vm.prank(bob);
    _ERC721PetSystem.safeTransferFrom(bob, eve, 0, "");

    _assertOwnership(0, eve);
    _assertOperator(petOneEntityID, eve);
  }

  function testChangeOperator() public {
    _mintPets(1);

    vm.prank(alice);
    _OperatorSetSystem.executeTyped(petOneEntityID, bob);

    _assertOwnership(0, alice);
    _assertOperator(petOneEntityID, bob);
  }
}
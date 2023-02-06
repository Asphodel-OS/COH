// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/TestSetupImports.sol";

contract SetupTemplate is TestSetupImports {
  uint256 petOneEntityID;
  uint256 petTwoEntityID;
  uint256 petThreeEntityID;

  address constant _deployerAddress = address(0);

  function setUp() public virtual override {
    super.setUp();
  }

  /***********************
  *   minting pets
  ************************/

  function _mintPets(uint256 n) internal virtual {
    require(n <= 3, "MUDTest: max three non-admin test accounts");
    if (n > 0) petOneEntityID = _mintSinglePet(alice);
    if (n > 1) petTwoEntityID = _mintSinglePet(bob);
    if (n > 2) petThreeEntityID = _mintSinglePet(eve); 
  }

  function _mintSinglePet(address addy) internal virtual returns (uint256) {
    vm.prank(addy, addy);
    return _ERC721PetSystem.mint(addy);
  }

  function _petIDToEntityID(uint256 id) internal virtual returns (uint256) {
    // may introduce unchecked error if no ID minted
    return _ERC721PetSystem.nftToEntityID(id);
  }
}

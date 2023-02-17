// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "test/utils/SetupTemplate.s.sol";

uint256 constant START = 100000000;

contract FoodTest is SetupTemplate {
  // function setUp() public override {
  //   super.setUp();
  //   // vm.prank(deployer);
  //   // __InitSystem.executeTyped();

  //   vm.warp(START);
  //   _mintPets(1);
  // }

  // function testCharge() public {
  //   assertEq(
  //     150, // max charge
  //     LibBattery.cal(components, petOneEntityID)
  //   );

  //   vm.warp(START + 10 seconds);
  //   assertEq(140, LibBattery.cal(components, petOneEntityID));

  //   vm.warp(START + 150 seconds);
  //   assertEq(0, LibBattery.cal(components, petOneEntityID));
  // }
}

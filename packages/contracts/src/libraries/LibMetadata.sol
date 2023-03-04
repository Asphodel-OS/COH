// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

// NOTE: should this be here? its not related to other MUD libs at all
library LibMetadata {
  uint256 constant SIZE = 8; //uint8, max elements = 256/8 = 32

  function _updateSingle(
    uint256 newElement,
    uint256 position,
    uint256 maxPos,
    uint256 packed
  ) internal pure returns (uint256) {
    require(position < (256 / SIZE) && position <= maxPos, "out of bounds");
    require(newElement < (1 << SIZE), "new num out of bounds");

    return
      (packed & ~(((1 << SIZE) - 1) << (SIZE * (maxPos - position)))) |
      (newElement << (SIZE * (maxPos - position)));
  }

  function _requireBelowMaxSingle(
    uint256 newElement,
    uint256 position,
    uint256 maxPos,
    uint256 packed
  ) internal pure {
    uint256 cMax = (packed >> (SIZE * (maxPos - position))) & ((1 << SIZE) - 1);

    require(cMax >= newElement, "new element >= max element");
  }

  function _generateFromSeed(
    uint256 seed,
    uint256 pMax,
    uint256 numElements
  ) internal pure returns (uint256) {
    // uint256 seed = uint256(keccak256(abi.encodePacked(randomSeed, tokenId)));

    // only take set number of elements
    seed = seed & ((1 << (SIZE * numElements)) - 1);

    // iterate to generate result
    uint256 result;
    for (uint256 i; i < numElements; i++) {
      // non-defult items always have a max 0
      uint256 cMax = (pMax >> (SIZE * i)) & ((1 << SIZE) - 1);
      uint256 cSeed = (seed >> (SIZE * i)) & ((1 << SIZE) - 1);

      // skip if 0
      if (cMax == 0) {
        result = result << SIZE;
        continue;
      }

      result = (result << SIZE) | ((cSeed % cMax) + 1);
    }

    return result;
  }

  function _packedToArray(
    uint256 packed,
    uint256 numElements 
  ) internal pure returns (uint256[] memory) {
    uint256[] memory result = new uint256[](numElements);

    for (uint256 i; i < numElements; i++) {
      // packed order is reversed
      // result[numElements-1-i] = packed & ((1 << SIZE) - 1);
      result[i] = packed & ((1 << SIZE) - 1);

      packed = packed >> SIZE;
    }

    return result;
  }

  function _generateMaxElements(uint256[] memory maxElements) internal pure returns (uint256) {
    uint256 result;
    for (uint256 i; i < maxElements.length; i++) {
      require(maxElements[i] < (1 << SIZE) - 1, "max over limit");
      result = (result << SIZE) | maxElements[i];
    }

    return result;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { getAddressById } from "solecs/utils.sol";

import { CoinComponent, ID as CoinComponentID } from "components/CoinComponent.sol";

library LibCoin {
  // gets the coin balance of an entity
  function getBalance(IUint256Component components, uint256 entityID)
    internal
    view
    returns (uint256)
  {
    return CoinComponent(getAddressById(components, CoinComponentID)).getValue(entityID);
  }

  // transfers the specified coin amt from=>to entity
  function transferBalance(
    IUint256Component components,
    uint256 fromID,
    uint256 toID,
    uint256 amt
  ) internal {
    decBalance(components, fromID, amt);
    incBalance(components, toID, amt);
  }

  // increases the coin balance of an entity by amt
  function incBalance(
    IUint256Component components,
    uint256 entityID,
    uint256 amt
  ) internal {
    uint256 balance = getBalance(components, entityID);
    setBalance(components, entityID, balance + amt);
  }

  // decreases the coin balance of an entity by amt
  function decBalance(
    IUint256Component components,
    uint256 entityID,
    uint256 amt
  ) internal {
    uint256 balance = getBalance(components, entityID);
    require(balance >= amt, "Coin: insufficient balance");
    unchecked {
      setBalance(components, entityID, balance - amt);
    }
  }

  // sets the coin balance of an entity
  function setBalance(
    IUint256Component components,
    uint256 entityID,
    uint256 amt
  ) internal {
    CoinComponent(getAddressById(components, CoinComponentID)).set(entityID, amt);
  }
}

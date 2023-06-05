// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { VRFCoordinatorV2Interface } from
  "chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFCoordinatorV2Mock } from "chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { Casino } from "../src/Casino.sol";
import { Test } from "forge-std/Test.sol";

contract CasinoTest is Test {
  address user1 = makeAddr("user1");
  address user2 = makeAddr("user2");
  address house = makeAddr("house");
  bytes32 keyhash = keccak256("hello");

  uint256 fee = 5;
  uint64 subId;

  VRFCoordinatorV2Interface vrf;
  Casino casino;

  function setUp() public {
    vrf = new VRFCoordinatorV2Mock(0, 0);
    subId = vrf.createSubscription();
    casino = new Casino(user1, user2, house, vrf, subId, keyhash, fee);
    vrf.addConsumer(subId, address(casino));
  }

  function test_betUser1() public {
    hoax(user1, 1 ether);
    casino.bet{ value: 1 ether }();

    assertEq(user1.balance, 0 ether);
    assertEq(address(casino).balance, 1 ether);
  }

  function test_fullfill() public {
    hoax(user1, 1 ether);
    casino.bet{ value: 1 ether }();
    hoax(user2, 1 ether);
    casino.bet{ value: 1 ether }();

    uint256[] memory randomWords = new uint[](1);
    randomWords[0] = 2; // even => user1 wins

    hoax(address(vrf));
    casino.rawFulfillRandomWords(1, randomWords);

    assertEq(user1.balance, 1.9 ether);
    assertEq(house.balance, 0.1 ether);
  }
}

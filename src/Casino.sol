// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { VRFCoordinatorV2Interface } from
  "chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Casino is VRFConsumerBaseV2 {
  address user1;
  address user2;
  address house;
  VRFCoordinatorV2Interface vrf;
  uint64 subId;
  bytes32 keyhash;
  uint256 fee; // in percent

  mapping(address => uint256) bets;

  constructor(
    address _user1,
    address _user2,
    address _house,
    VRFCoordinatorV2Interface _vrf,
    uint64 _subId,
    bytes32 _keyhash,
    uint256 _fee
  ) VRFConsumerBaseV2(address(_vrf)) {
    user1 = _user1;
    user2 = _user2;
    house = _house;
    vrf = _vrf;
    subId = _subId;
    keyhash = _keyhash;
    fee = _fee;
  }

  function bet() external payable {
    require(msg.sender == user1 || msg.sender == user2, "You are not a player");
    require(bets[msg.sender] == 0, "You already played!");
    require(msg.value > 0, "Not enough Ether");

    bets[msg.sender] = msg.value;

    if (bets[user1] > 0 && bets[user2] > 0) {
      vrf.requestRandomWords(keyhash, subId, 10, 1e6, 1);
    }
  }

  function roll(uint256 random) internal {
    address winner;

    if (random % 2 == 0) {
      winner = user1; // even: user 1 wins
    } else {
      winner = user2; // odd: user 2 wins
    }

    // send the ether to the winner + the house
    uint256 total = address(this).balance;
    uint256 gain = total * (100 - fee) / 100;
    payable(winner).transfer(gain);
    payable(house).transfer(total - gain);
  }

  function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
    require(randomWords.length > 0, "Empty randomWords");
    roll(randomWords[0]);
  }
}

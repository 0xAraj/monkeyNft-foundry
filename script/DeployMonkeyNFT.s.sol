//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {MonkeyNFT} from "../src/MonkeyNFT.sol";
import {Script} from "forge-std/Script.sol";

contract DeployMonkeyNFT is Script {
    MonkeyNFT monkeyNFT;

    function run() external returns (MonkeyNFT) {
        vm.startBroadcast();
        monkeyNFT = new MonkeyNFT();
        vm.stopBroadcast();
        return monkeyNFT;
    }
}

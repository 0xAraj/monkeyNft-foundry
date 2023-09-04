//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MonkeyNFT} from "../../src/MonkeyNFT.sol";

contract Handler is Test {
    MonkeyNFT monkeyNFT;

    constructor(MonkeyNFT _monkeyNFT) {
        monkeyNFT = _monkeyNFT;
    }

    function getWhitelist() public {
        bool alreadyWhitelistUser = monkeyNFT.getWhiteListAddress();
        if (alreadyWhitelistUser) {
            return;
        }
        monkeyNFT.getWhiteList();
    }

    // function publicMint(uint256 quantity) public {
    //     quantity = bound(quantity, 1, 3);
    //     uint256 amount = 0.01 ether * quantity;
    //     startHoax(address(uint160(quantity)), 10 ether);
    //     //  vm.deal(msg.sender, 10 ether);
    //     monkeyNFT.publicMint{value: amount}(quantity);
    // }
}

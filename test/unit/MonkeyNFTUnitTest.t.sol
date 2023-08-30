//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMonkeyNFT} from "../../script/DeployMonkeyNFT.s.sol";
import {MonkeyNFT} from "../../src/MonkeyNFT.sol";

contract MonkeyNFTUnitTest is Test {
    DeployMonkeyNFT deployMonkeyNFT;
    MonkeyNFT monkeyNFT;
    address USER = makeAddr("user");

    event Whitelist(address user);

    function setUp() external {
        deployMonkeyNFT = new DeployMonkeyNFT();
        monkeyNFT = deployMonkeyNFT.run();
    }

    function testNameAndSymbolIsSetCorrectly() public view {
        string memory expectedName = "Monkey";
        string memory expectedSymbol = "MKY";

        string memory actualName = monkeyNFT.name();
        string memory actualSymbol = monkeyNFT.symbol();

        assert(keccak256(abi.encodePacked(actualName)) == keccak256(abi.encodePacked(expectedName)));
        assert(keccak256(abi.encodePacked(actualSymbol)) == keccak256(abi.encodePacked(expectedSymbol)));
    }

    function testShouldSetOwnerToMsgSender() public {
        vm.startPrank(USER);
        MonkeyNFT monkey = new MonkeyNFT();

        address owner = monkey.owner();
        assert(owner == USER);
    }

    function testShouldReturnCorrectBaseUri() public view {
        string memory expectedBaseUri = "https://ipfs.io/ipfs/QmXXzRSwSPs4DHLS7RDPRyG1GinjGVFv2fS5TdX3fW33FX/";

        string memory actualBaseUri = monkeyNFT.getBaseUri();
        assert(keccak256(abi.encodePacked(actualBaseUri)) == keccak256(abi.encodePacked(expectedBaseUri)));
    }

    function testRevetGetWhitelistIfAlreadyWhitelisted() public {
        vm.startPrank(USER);
        monkeyNFT.getWhiteList();

        vm.startPrank(USER);
        vm.expectRevert();
        monkeyNFT.getWhiteList();
    }

    function testRevertGetWhitelistIfMaxWhitelistIsReached() public {
        uint256 MAX_WHITELIST_ADDRESS = 300;
        for (uint160 i = 1; i <= MAX_WHITELIST_ADDRESS; i++) {
            hoax(address(i));
            monkeyNFT.getWhiteList();
        }
        uint256 totalWhitelistAddress = monkeyNFT.TOTAL_WHITELIST_ADDRESS();
        assert(totalWhitelistAddress == MAX_WHITELIST_ADDRESS);
        vm.startPrank(USER);
        vm.expectRevert();
        monkeyNFT.getWhiteList();
    }

    function testGetWhitelistShouldUpdateDateAndEmitEvent() public {
        vm.startPrank(USER);
        vm.expectEmit(address(monkeyNFT));
        emit Whitelist(USER);
        monkeyNFT.getWhiteList();

        uint256 totalWhitelistAddress = monkeyNFT.TOTAL_WHITELIST_ADDRESS();
        assert(totalWhitelistAddress == 1);
        assert(monkeyNFT.getWhiteListAddress());
    }
}

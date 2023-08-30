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
    event MintedNFT(address indexed buyer, uint256 indexed tokenId, uint256 indexed quantity);

    function setUp() external {
        deployMonkeyNFT = new DeployMonkeyNFT();
        monkeyNFT = deployMonkeyNFT.run();
        vm.deal(USER, 100 ether);
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

    function testRevertPublicMintIfQuantityIsZero() public {
        uint256 quantity = 0;
        vm.startPrank(USER);
        vm.expectRevert();
        monkeyNFT.publicMint(quantity);
    }

    function testRevertPublicMintIfTotalSupplyExcededMaxSupply() public {
        uint256 quantity = 2;
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 amount = quantity * priceOfOneNFT;

        for (uint160 i = 1; i <= 1000; i++) {
            hoax(address(i), 1 ether);
            monkeyNFT.publicMint{value: amount}(quantity);
        }

        uint256 totalSupply = monkeyNFT.totalSupply();
        assert(totalSupply == 2000);
        vm.expectRevert();
        monkeyNFT.publicMint(1);
    }

    function testRevertPublicMintIfExactPriceIsNotPaid() public {
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 quantity = 2;
        uint256 amount = 1 * priceOfOneNFT;

        vm.startPrank(USER);
        vm.expectRevert();
        monkeyNFT.publicMint{value: amount}(quantity);
    }

    function testRevertPublicMintIfMintPerWalletIsMoreThanThree() public {
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 quantity = 3;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.publicMint{value: amount}(quantity);

        vm.expectRevert();
        monkeyNFT.publicMint{value: 0.01 ether}(1);
    }

    function testPublicMintShouldMintAndUpdateData() public {
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 quantity = 3;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.publicMint{value: amount}(quantity);

        uint256 balanceOfUser = monkeyNFT.balanceOf(USER);
        uint256 numberOfMintedNft = monkeyNFT.getMintedPerWallet();

        assert(balanceOfUser == quantity);
        assert(numberOfMintedNft == quantity);
    }

    function testPublicMintShouldEmitEvent() public {
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 quantity = 2;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        vm.expectEmit(address(monkeyNFT));
        emit MintedNFT(USER, 1, quantity); // you can also give 0 at place of 1
        monkeyNFT.publicMint{value: amount}(quantity);
    }

    function testRevertWhitelistMintIfQuantityIsZero() public {
        uint256 quantity = 0;
        uint256 amount = quantity * 0.001 ether;
        vm.startPrank(USER);
        monkeyNFT.getWhiteList();
        vm.expectRevert();
        monkeyNFT.whiteListMint{value: amount}(quantity);
        vm.stopPrank();
    }

    function testRevertWhitelistMintIfTotalSupplyExcededMaxSupply() public {
        uint256 quantity = 2;
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 amount = quantity * priceOfOneNFT;

        for (uint160 i = 1; i <= 1000; i++) {
            hoax(address(i), 1 ether);
            monkeyNFT.publicMint{value: amount}(quantity);
        }

        uint256 totalSupply = monkeyNFT.totalSupply();
        assert(totalSupply == 2000);
        vm.expectRevert();
        monkeyNFT.whiteListMint{value: 1 * 0.01 ether}(1);
    }

    function testRevertWhitelistMintIfUserIsNotWhitelisted() public {
        uint256 quantity = 2;
        uint256 priceOfOneNFT = 0.01 ether;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        vm.expectRevert();
        monkeyNFT.whiteListMint{value: amount}(quantity);
    }

    function testRevertWhitelistMintIfExactPriceIsNotPaid() public {
        uint256 priceOfOneNFT = 0.001 ether;
        uint256 quantity = 2;
        uint256 amount = 1 * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.getWhiteList();
        vm.expectRevert();
        monkeyNFT.whiteListMint{value: amount}(quantity);
    }

    function testRevertwhitelistMintIfMintPerWalletIsMoreThanThree() public {
        uint256 priceOfOneNFT = 0.001 ether;
        uint256 quantity = 3;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.getWhiteList();
        monkeyNFT.whiteListMint{value: amount}(quantity);

        vm.expectRevert();
        monkeyNFT.whiteListMint{value: 0.001 ether}(1);
    }

    function testWhitelistMintShouldMintAndUpdateData() public {
        uint256 priceOfOneNFT = 0.001 ether;
        uint256 quantity = 3;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.getWhiteList();
        monkeyNFT.whiteListMint{value: amount}(quantity);

        uint256 balanceOfUser = monkeyNFT.balanceOf(USER);
        uint256 numberOfMintedNft = monkeyNFT.getMintedPerWallet();

        assert(balanceOfUser == quantity);
        assert(numberOfMintedNft == quantity);
    }

    function testWhitelistMintShouldEmitEvent() public {
        uint256 priceOfOneNFT = 0.001 ether;
        uint256 quantity = 2;
        uint256 amount = quantity * priceOfOneNFT;

        vm.startPrank(USER);
        monkeyNFT.getWhiteList();
        vm.expectEmit(address(monkeyNFT));
        emit MintedNFT(USER, 1, quantity); // you can also give 0 at place of 1
        monkeyNFT.whiteListMint{value: amount}(quantity);
    }
}

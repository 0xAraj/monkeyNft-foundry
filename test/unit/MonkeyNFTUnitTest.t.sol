// //SPDX-License-Identifier: MIT

// pragma solidity 0.8.20;

// import {Test, console} from "forge-std/Test.sol";
// import {DeployMonkeyNFT} from "../../script/DeployMonkeyNFT.s.sol";
// import {MonkeyNFT} from "../../src/MonkeyNFT.sol";

// contract MonkeyNFTUnitTest is Test {
//     DeployMonkeyNFT deployMonkeyNFT;
//     MonkeyNFT monkeyNFT;
//     address USER = makeAddr("user");
//     address RAJ = makeAddr("raj");

//     event Whitelist(address user);
//     event MintedNFT(address indexed buyer, uint256 indexed tokenId, uint256 indexed quantity);
//     event Listed(uint256 indexed tokenId, uint256 indexed listPrice, address approvedAccount);
//     event Sold(uint256 indexed tokenId, address indexed seller, address previousOwner);
//     event WithdrawFunds(address indexed to, uint256 indexed amount);

//     function setUp() external {
//         deployMonkeyNFT = new DeployMonkeyNFT();
//         monkeyNFT = deployMonkeyNFT.run();
//         vm.deal(USER, 100 ether);
//         vm.deal(RAJ, 100 ether);
//     }

//     function testNameAndSymbolIsSetCorrectly() public view {
//         string memory expectedName = "Monkey";
//         string memory expectedSymbol = "MKY";

//         string memory actualName = monkeyNFT.name();
//         string memory actualSymbol = monkeyNFT.symbol();

//         assert(keccak256(abi.encodePacked(actualName)) == keccak256(abi.encodePacked(expectedName)));
//         assert(keccak256(abi.encodePacked(actualSymbol)) == keccak256(abi.encodePacked(expectedSymbol)));
//     }

//     function testShouldSetOwnerToMsgSender() public {
//         vm.startPrank(USER);
//         MonkeyNFT monkey = new MonkeyNFT();

//         address owner = monkey.owner();
//         assert(owner == USER);
//     }

//     function testShouldReturnCorrectBaseUri() public view {
//         string memory expectedBaseUri = "https://ipfs.io/ipfs/QmXXzRSwSPs4DHLS7RDPRyG1GinjGVFv2fS5TdX3fW33FX/";

//         string memory actualBaseUri = monkeyNFT.getBaseUri();
//         assert(keccak256(abi.encodePacked(actualBaseUri)) == keccak256(abi.encodePacked(expectedBaseUri)));
//     }

//     function testRevetGetWhitelistIfAlreadyWhitelisted() public {
//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();

//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.getWhiteList();
//     }

//     function testRevertGetWhitelistIfMaxWhitelistIsReached() public {
//         uint256 MAX_WHITELIST_ADDRESS = 300;
//         for (uint160 i = 1; i <= MAX_WHITELIST_ADDRESS; i++) {
//             hoax(address(i));
//             monkeyNFT.getWhiteList();
//         }
//         uint256 totalWhitelistAddress = monkeyNFT.TOTAL_WHITELIST_ADDRESS();
//         assert(totalWhitelistAddress == MAX_WHITELIST_ADDRESS);
//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.getWhiteList();
//     }

//     function testGetWhitelistShouldUpdateDateAndEmitEvent() public {
//         vm.startPrank(USER);
//         vm.expectEmit(address(monkeyNFT));
//         emit Whitelist(USER);
//         monkeyNFT.getWhiteList();

//         uint256 totalWhitelistAddress = monkeyNFT.TOTAL_WHITELIST_ADDRESS();
//         assert(totalWhitelistAddress == 1);
//         assert(monkeyNFT.getWhiteListAddress());
//     }

//     function testRevertPublicMintIfQuantityIsZero() public {
//         uint256 quantity = 0;
//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.publicMint(quantity);
//     }

//     function testRevertPublicMintIfTotalSupplyExcededMaxSupply() public {
//         uint256 quantity = 2;
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 amount = quantity * priceOfOneNFT;

//         for (uint160 i = 1; i <= 1000; i++) {
//             hoax(address(i), 1 ether);
//             monkeyNFT.publicMint{value: amount}(quantity);
//         }

//         uint256 totalSupply = monkeyNFT.totalSupply();
//         assert(totalSupply == 2000);
//         vm.expectRevert();
//         monkeyNFT.publicMint(1);
//     }

//     function testRevertPublicMintIfExactPriceIsNotPaid() public {
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 quantity = 2;
//         uint256 amount = 1 * priceOfOneNFT;

//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.publicMint{value: amount}(quantity);
//     }

//     function testRevertPublicMintIfMintPerWalletIsMoreThanThree() public {
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 quantity = 3;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         vm.expectRevert();
//         monkeyNFT.publicMint{value: 0.01 ether}(1);
//     }

//     function testPublicMintShouldMintAndUpdateData() public {
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 quantity = 3;
//         uint256 amount = quantity * priceOfOneNFT;
//         uint256 tokenId = 1;

//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         // this call will save the struct from mapping in the forTestingPurposeOnly and we'll easily access that.
//         monkeyNFT.getMintedNftForTesting(tokenId);
//         (
//             uint256 storedTokenId,
//             uint256 storedListPrice,
//             address payable storedSeller,
//             address payable storedOwner,
//             bool storedIsListed
//         ) = monkeyNFT.forTestingPurposeOnly();

//         assert(storedTokenId == tokenId);
//         assert(storedListPrice == 0);
//         assert(storedSeller == address(0));
//         assert(storedOwner == USER);
//         assert(!storedIsListed);

//         uint256 balanceOfUser = monkeyNFT.balanceOf(USER);
//         uint256 numberOfMintedNft = monkeyNFT.getMintedPerWallet();

//         assert(balanceOfUser == quantity);
//         assert(numberOfMintedNft == quantity);
//     }

//     function testPublicMintShouldEmitEvent() public {
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 quantity = 2;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         vm.expectEmit(address(monkeyNFT));
//         emit MintedNFT(USER, 1, quantity); // you can also give 0 at place of 1
//         monkeyNFT.publicMint{value: amount}(quantity);
//     }

//     function testRevertWhitelistMintIfQuantityIsZero() public {
//         uint256 quantity = 0;
//         uint256 amount = quantity * 0.001 ether;
//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         vm.expectRevert();
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//         vm.stopPrank();
//     }

//     function testRevertWhitelistMintIfTotalSupplyExcededMaxSupply() public {
//         uint256 quantity = 2;
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 amount = quantity * priceOfOneNFT;

//         for (uint160 i = 1; i <= 1000; i++) {
//             hoax(address(i), 1 ether);
//             monkeyNFT.publicMint{value: amount}(quantity);
//         }

//         uint256 totalSupply = monkeyNFT.totalSupply();
//         assert(totalSupply == 2000);
//         monkeyNFT.getWhiteList();
//         vm.expectRevert();
//         monkeyNFT.whiteListMint{value: 1 * 0.01 ether}(1);
//     }

//     function testRevertWhitelistMintIfUserIsNotWhitelisted() public {
//         uint256 quantity = 2;
//         uint256 priceOfOneNFT = 0.01 ether;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//     }

//     function testRevertWhitelistMintIfExactPriceIsNotPaid() public {
//         uint256 priceOfOneNFT = 0.001 ether;
//         uint256 quantity = 2;
//         uint256 amount = 1 * priceOfOneNFT;

//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         vm.expectRevert();
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//     }

//     function testRevertwhitelistMintIfMintPerWalletIsMoreThanThree() public {
//         uint256 priceOfOneNFT = 0.001 ether;
//         uint256 quantity = 3;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         monkeyNFT.whiteListMint{value: amount}(quantity);

//         vm.expectRevert();
//         monkeyNFT.whiteListMint{value: 0.001 ether}(1);
//     }

//     function testWhitelistMintShouldMintAndUpdateData() public {
//         uint256 priceOfOneNFT = 0.001 ether;
//         uint256 quantity = 3;
//         uint256 amount = quantity * priceOfOneNFT;
//         uint256 tokenId = 1;

//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//         // this call will save the struct from mapping in the forTestingPurposeOnly and we'll easily access that.
//         monkeyNFT.getMintedNftForTesting(tokenId);
//         (
//             uint256 storedTokenId,
//             uint256 storedListPrice,
//             address payable storedSeller,
//             address payable storedOwner,
//             bool storedIsListed
//         ) = monkeyNFT.forTestingPurposeOnly();

//         assert(storedTokenId == tokenId);
//         assert(storedListPrice == 0);
//         assert(storedSeller == address(0));
//         assert(storedOwner == USER);
//         assert(!storedIsListed);

//         uint256 balanceOfUser = monkeyNFT.balanceOf(USER);
//         uint256 numberOfMintedNft = monkeyNFT.getMintedPerWallet();

//         assert(balanceOfUser == quantity);
//         assert(numberOfMintedNft == quantity);
//     }

//     function testWhitelistMintShouldEmitEvent() public {
//         uint256 priceOfOneNFT = 0.001 ether;
//         uint256 quantity = 2;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         vm.expectEmit(address(monkeyNFT));
//         emit MintedNFT(USER, 1, quantity); // you can also give 0 at place of 1
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//     }

//     function testRevertListNFTIfAlreadyListed() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: 0.01 ether}(tokenId, 0.1 ether);

//         vm.expectRevert();
//         monkeyNFT.listNFT{value: 0.01 ether}(tokenId, 0.1 ether);
//     }

//     function testRevertListNFTIfListerIsNotOwnerOfNFT() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         vm.startPrank(RAJ);
//         vm.expectRevert();
//         monkeyNFT.listNFT{value: 0.01 ether}(tokenId, 0.1 ether);
//     }

//     function testRevertListNFTIfListPriceIsNotSame() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         vm.expectRevert();
//         monkeyNFT.listNFT{value: 0.001 ether}(tokenId, listPrice);
//     }

//     function testListNFTShouldUpdateData() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);
//         // this call will save the struct from mapping in the forTestingPurposeOnly and we'll easily access that.
//         monkeyNFT.getMintedNftForTesting(tokenId);

//         (
//             uint256 storedTokenId,
//             uint256 storedListPrice,
//             address payable storedSeller,
//             address payable storedOwner,
//             bool storedIsListed
//         ) = monkeyNFT.forTestingPurposeOnly();
//         uint256 listedNFTlength = monkeyNFT.getListedNFTLength();
//         address approvedAddressForNFT = monkeyNFT.getApproved(tokenId);

//         assert(storedTokenId == tokenId);
//         assert(storedListPrice == listPrice);
//         assert(storedSeller == address(monkeyNFT));
//         assert(storedOwner == USER);
//         assert(storedIsListed);
//         assert(listedNFTlength == 1);
//         assert(approvedAddressForNFT == address(monkeyNFT));
//     }

//     function testListNFTShouldEmitAnEvent() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         vm.expectEmit(address(monkeyNFT));
//         emit Listed(tokenId, listPrice, address(monkeyNFT));
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);
//     }

//     function testRevertUpdatePriceIfPriceIsZero() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 updatePrice = 0 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.expectRevert();
//         monkeyNFT.updateListPrice(tokenId, updatePrice);
//     }

//     function testRevertUpdateListPriceIfCallerIsNotOwner() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 updatePrice = 1 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.startPrank(RAJ);
//         vm.expectRevert();
//         monkeyNFT.updateListPrice(tokenId, updatePrice);
//     }

//     function testRevertUpdateListPriceIfNftIsNotListed() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 updatePrice = 1 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         vm.expectRevert();
//         monkeyNFT.updateListPrice(tokenId, updatePrice);
//     }

//     function testShouldUpdateListPrice() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 updatePrice = 1 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         monkeyNFT.updateListPrice(tokenId, updatePrice);
//         monkeyNFT.getMintedNftForTesting(tokenId);
//         (, uint256 storedListPrice,,,) = monkeyNFT.forTestingPurposeOnly();
//         assert(storedListPrice == updatePrice);
//     }

//     function testRevertBuyNftIfNftIsNotListed() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 listingId = 1;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.startPrank(RAJ);
//         vm.expectRevert();
//         monkeyNFT.buyNFT{value: listPrice}(listingId);
//     }

//     function testRevertBuyNftIfExactPriceIsNotPaid() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 listingId = 0;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.startPrank(RAJ);
//         vm.expectRevert();
//         monkeyNFT.buyNFT{value: listPrice - 0.01 ether}(listingId);
//     }

//     function testShouldBuyNftAndUpdateData() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 listingId = 0;
//         uint256 initialBalanceOfRaj = RAJ.balance;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.startPrank(RAJ);
//         monkeyNFT.buyNFT{value: listPrice}(listingId);

//         // this call will save the struct from mapping in the forTestingPurposeOnly and we'll easily access that.
//         monkeyNFT.getMintedNftForTesting(tokenId);

//         (
//             uint256 storedTokenId,
//             uint256 storedListPrice,
//             address payable storedSeller,
//             address payable storedOwner,
//             bool storedIsListed
//         ) = monkeyNFT.forTestingPurposeOnly();
//         uint256 balanceOfRaj = monkeyNFT.balanceOf(RAJ);
//         uint256 balanceOfUser = monkeyNFT.balanceOf(USER);
//         address ownerOfTokenIdOne = monkeyNFT.ownerOf(tokenId);
//         uint256 finalBalanceOfRaj = RAJ.balance;

//         assert(storedTokenId == tokenId);
//         assert(storedListPrice == listPrice);
//         assert(storedSeller == address(monkeyNFT));
//         assert(storedOwner == RAJ);
//         assert(!storedIsListed);
//         assert(balanceOfRaj == 1);
//         assert(balanceOfUser == 1); // because 1 nft transfered to raj
//         assert(ownerOfTokenIdOne == RAJ);
//         assert(finalBalanceOfRaj == initialBalanceOfRaj - listPrice);
//     }

//     function testBuyNftShouldEmitAnEvent() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         uint256 tokenId = 1;
//         uint256 listPrice = 0.1 ether;
//         uint256 listingFee = 0.01 ether;
//         uint256 listingId = 0;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         monkeyNFT.listNFT{value: listingFee}(tokenId, listPrice);

//         vm.startPrank(RAJ);
//         vm.expectEmit(address(monkeyNFT));
//         emit Sold(tokenId, address(monkeyNFT), USER);
//         monkeyNFT.buyNFT{value: listPrice}(listingId);
//     }

//     function tesWithdrawFunction() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         uint256 initialContractBalance = address(monkeyNFT).balance;
//         uint256 initialRajBalance = RAJ.balance;

//         vm.startPrank(USER);
//         monkeyNFT.withdrawFunds(RAJ);
//         uint256 finalRajBalance = RAJ.balance;
//         uint256 finalContractBalance = address(monkeyNFT).balance;
//         assert(finalRajBalance == initialRajBalance + initialContractBalance);
//         assert(finalContractBalance == 0);
//     }

//     function testWithdrawFundsShouldEmitAnEvent() public {
//         uint256 quantity = 2;
//         uint256 amount = quantity * 0.01 ether;
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);
//         uint256 initialContractBalance = address(monkeyNFT).balance;

//         vm.startPrank(monkeyNFT.owner());
//         vm.expectEmit(address(monkeyNFT));
//         emit WithdrawFunds(RAJ, initialContractBalance);
//         monkeyNFT.withdrawFunds(RAJ);
//     }

//     function testRevertTokenUriIfTokenIdNotMinted() public {
//         uint256 tokenId = 1;

//         vm.startPrank(USER);
//         vm.expectRevert();
//         monkeyNFT.tokenURI(tokenId);
//     }

//     function testShouldReturnTokenURI() public {
//         uint256 quantity = 2;
//         uint256 tokenId = 1;
//         uint256 amount = quantity * 0.01 ether;
//         string memory expectedTokenUri = "https://ipfs.io/ipfs/QmXXzRSwSPs4DHLS7RDPRyG1GinjGVFv2fS5TdX3fW33FX/5001.json";
//         vm.startPrank(USER);
//         monkeyNFT.publicMint{value: amount}(quantity);

//         string memory actualTokenUri = monkeyNFT.tokenURI(tokenId);
//         assert(keccak256(abi.encodePacked(expectedTokenUri)) == keccak256(abi.encodePacked(actualTokenUri)));
//     }

//     function testShouldReturnMyNFTs() public {
//         uint256 priceOfOneNFT = 0.001 ether;
//         uint256 quantity = 3;
//         uint256 amount = quantity * priceOfOneNFT;

//         vm.startPrank(USER);
//         monkeyNFT.getWhiteList();
//         monkeyNFT.whiteListMint{value: amount}(quantity);
//         monkeyNFT.myNFTs();

//         uint256 myTotalNft = monkeyNFT.getMyNftLength();
//         for (uint256 i = 0; i < myTotalNft; i++) {
//             monkeyNFT.getMyNFTsForTesting(i);
//             (,,, address payable storedOwner,) = monkeyNFT.forTestingPurposeOnly();

//             assert(storedOwner == USER);
//         }
//     }
// }

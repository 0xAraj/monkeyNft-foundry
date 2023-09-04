//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployMonkeyNFT} from "../../script/DeployMonkeyNFT.s.sol";
import {MonkeyNFT} from "../../src/MonkeyNFT.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    MonkeyNFT monkeyNFT;
    Handler handler;

    function setUp() external {
        DeployMonkeyNFT deployMonkeyNFT = new DeployMonkeyNFT();
        monkeyNFT = deployMonkeyNFT.run();
        handler = new Handler(monkeyNFT);
        targetContract(address(handler));
    }

    //Whitelist address should not be more than MaxLimit ie. 300
    function invariant_protocolShouldNeverWhitelistMoreThanMaxLimit() public view {
        uint256 maxLimitOfWhitlist = monkeyNFT.MAX_WHITELIST_ADDRESS();
        uint256 currentWhitelistAddress = monkeyNFT.TOTAL_WHITELIST_ADDRESS();

        console.log(currentWhitelistAddress);
        assert(maxLimitOfWhitlist >= currentWhitelistAddress);
    }

    // //Total supply or total minted nft should never exceed max supply
    // function invariant_protocolMustNotExeeedMaxSupplyOfNFTs() public view {
    //     uint256 maxSupplyOfNft = monkeyNFT.MAX_SUPPLY();
    //     uint256 totalMintedNft = monkeyNFT.totalSupply();

    //     console.log(totalMintedNft);
    //     assert(maxSupplyOfNft >= totalMintedNft);
    // }

    // //A user should not mint more than 3 nft
    // function invariant_userShouldNotMintMoreThanThreeNft() public view {
    //     uint256 nftMintedPerWallet = monkeyNFT.getMintedPerWallet();

    //     console.log(nftMintedPerWallet);
    //     assert(nftMintedPerWallet <= 3);
    // }
}

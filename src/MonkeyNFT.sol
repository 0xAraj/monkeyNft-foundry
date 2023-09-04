// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MonkeyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    //Public Variables
    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public constant PUBLIC_MINT_PRICE = 0.01 ether;
    uint256 public constant WHITELIST_MINT_PRICE = 0.001 ether;
    uint256 public constant MAX_WHITELIST_ADDRESS = 300;
    uint256 public constant LIST_PRICE = 0.01 ether;
    uint256 public TOTAL_WHITELIST_ADDRESS;
    string public s_baseExtension = ".json";

    //Contains info about minted NFTs
    struct NFTdetails {
        uint256 tokenId;
        uint256 listPrice;
        address payable seller;
        address payable owner;
        bool isListed;
    }
    // Array of all listed NFTs on our marketplace

    NFTdetails[] private s_allListedNFTs;

    //You can't access struct from mapping to test uing a getter function, so I've made this public struct that will return struct that is in mapping.It has been used in getter function which is down.
    NFTdetails public forTestingPurposeOnly;

    //This will return your all NFTs
    NFTdetails[] private yourNFTs;

    //Keeps track of all minted NFTs
    mapping(uint256 tokenId => NFTdetails) private s_mintedNFTs;
    //Track no. of NFTs minted per wallet
    mapping(address user => uint256 noOfNftMinted) private s_mintedWallet;
    //Track whether a address is whitelisted or not
    mapping(address user => bool isWhiteListed) private s_whiteListAddress;

    //Events
    event MintedNFT(address indexed buyer, uint256 indexed tokenId, uint256 indexed quantity);
    event WithdrawFunds(address indexed to, uint256 indexed amount);
    event Listed(uint256 indexed tokenId, uint256 indexed listPrice, address approvedAccount);
    event Sold(uint256 indexed tokenId, address indexed seller, address previousOwner);
    event Whitelist(address user);

    constructor() ERC721("Monkey", "MKY") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/QmXXzRSwSPs4DHLS7RDPRyG1GinjGVFv2fS5TdX3fW33FX/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //Main functions
    /*
     @dev This lets user get Whitelist.

     Requirement:-
     They should not be whitelisted already.
     Total whitelist address must be less than max whitelist address.
     Should update `s_whiteListAddress` mapping to true

     emits {Whitelist} event
    */
    function getWhiteList() public {
        require(!s_whiteListAddress[msg.sender], "Already added");
        require(TOTAL_WHITELIST_ADDRESS < MAX_WHITELIST_ADDRESS, "Max out");
        TOTAL_WHITELIST_ADDRESS++;
        s_whiteListAddress[msg.sender] = true;
        emit Whitelist(msg.sender);
    }

    /*
     @dev This allow user to mints NFT of given qunatity.

     Requirement:-
      quantity should not be zero.
      totalSupply should not excede max supply after minting
      should update `s_mintedWallet` mapping

    @notice A user can only mint 3 NFT
    emit {MintedNFT} event
    */
    function publicMint(uint256 quantity) public payable {
        require(quantity > 0, "Quantity is zero!");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Sold out!");
        require(msg.value == PUBLIC_MINT_PRICE * quantity, "Please pay the exact amount!");
        require(s_mintedWallet[msg.sender] + quantity <= 3, "Max per wallet reached!");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            s_mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
            NFTdetails memory token;
            token.tokenId = tokenId;
            token.owner = payable(msg.sender);
            token.isListed = false;
            s_mintedNFTs[tokenId] = token;
            emit MintedNFT(msg.sender, tokenId, quantity);
        }
    }

    /*
     @dev This allow only whitelisted users to mint NFT of given quantity.

     Requirement:-
      quantity should not be zero.
      totalSupply should not excede max supply after minting
      should update `s_mintedWallet` mapping

    @notice A user can only mint 3 NFT
    emit {MintedNFT} event
    */
    function whiteListMint(uint256 quantity) public payable {
        require(quantity > 0, "Quantity is zero!");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Sold out!");
        require(s_whiteListAddress[msg.sender], "You are not in the whitelist!");
        require(msg.value == WHITELIST_MINT_PRICE * quantity, "Please pay the exact amount!");
        require(s_mintedWallet[msg.sender] + quantity <= 3, "Max per wallet reached!");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            s_mintedWallet[msg.sender]++;
            _safeMint(msg.sender, tokenId);
            NFTdetails memory token;
            token.tokenId = tokenId;
            token.owner = payable(msg.sender);
            token.isListed = false;
            s_mintedNFTs[tokenId] = token;
            emit MintedNFT(msg.sender, tokenId, quantity);
        }
    }

    /*
     @dev This allow users to list their nft on the marketplace

    Requirement:-
    User should be the owner of the NFT
    Must pay the listing price
    Should update `s_allListedNFTs` mapping to store listed NFT
    User should approve this contract to transfer the NFT on their behalf.

    emit {Listed} event
    */
    function listNFT(uint256 tokenId, uint256 _listPrice) public payable {
        require(!s_mintedNFTs[tokenId].isListed, "Already listed!");
        require(s_mintedNFTs[tokenId].owner == msg.sender, "You are not the owner of NFT");
        require(msg.value == LIST_PRICE, "Pay the exact price!");

        NFTdetails storage updateNFTdetails = s_mintedNFTs[tokenId];
        updateNFTdetails.listPrice = _listPrice * 1 wei;
        updateNFTdetails.seller = payable(address(this));
        updateNFTdetails.isListed = true;

        s_allListedNFTs.push(updateNFTdetails);
        approve(address(this), tokenId);
        emit Listed(tokenId, _listPrice, address(this));
    }

    /*
     @dev This updates the list price of listed NFT

     Requirements:-
     Only owner of the nft can update the price

    */
    function updateListPrice(uint256 tokenId, uint256 _listPrice) public {
        require(_listPrice > 0, "Price is zero!");
        require(s_mintedNFTs[tokenId].owner == msg.sender, "You are not the owner of NFT");
        require(s_mintedNFTs[tokenId].isListed, "Not Listed");

        uint256 length = s_allListedNFTs.length;
        s_mintedNFTs[tokenId].listPrice = _listPrice * 1 wei;
        for (uint256 i = 0; i < length; i++) {
            if (s_allListedNFTs[i].tokenId == tokenId) {
                s_allListedNFTs[i].listPrice = _listPrice * 1 wei;
            }
        }
    }

    /*
     @dev This returns the all the nft that the user holds
    */

    function myNFTs() public returns (NFTdetails[] memory) {
        uint256 tokenId = _tokenIdCounter.current();
        for (uint256 i = 0; i <= tokenId; i++) {
            NFTdetails storage item = s_mintedNFTs[i];
            if (item.owner == msg.sender) {
                yourNFTs.push(item);
            }
        }
        return yourNFTs;
    }

    /*
    @dev This lets you buy the NFT from our marketplace after paying the listing price.

    Requirements:-
    Should transfer the Nft from owner to buyer
    Should transfer the amout to owner of the NFT
    Should update both `s_mintedNFTs & s_allListedNFTs` mapping

    emit {Sold} event
    */
    function buyNFT(uint256 id) public payable {
        require(s_allListedNFTs[id].isListed, "Sold out!");
        require(msg.value == s_allListedNFTs[id].listPrice, "Pay the exact amount!");

        uint256 tokenId = s_allListedNFTs[id].tokenId;
        address owner = s_allListedNFTs[id].owner;
        s_mintedNFTs[tokenId].isListed = false;
        s_allListedNFTs[id].isListed = false;

        s_mintedNFTs[tokenId].owner = payable(msg.sender);
        s_allListedNFTs[id].owner = payable(msg.sender);

        this.safeTransferFrom(owner, msg.sender, tokenId);
        payable(owner).transfer(msg.value);
        emit Sold(tokenId, address(this), owner);
    }

    /*
      @dev This withdraws the funds from contract to given `to` address

      Requirement:-
      Only owner of the contract can call this function 

      emit {WhithdrawFunds} event
    */
    function withdrawFunds(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
        emit WithdrawFunds(to, balance);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    //Returns the tokenURI of tokens for marketpalces to fetch metadata
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireMinted(tokenId);

        string memory base = _baseURI();
        uint256 num = 5000 + tokenId;
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(base).length > 0) {
            return string(abi.encodePacked(base, num.toString(), s_baseExtension));
        }

        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //Getter functions

    function getBaseUri() external pure returns (string memory) {
        return _baseURI();
    }

    function getWhiteListAddress() external view returns (bool) {
        return s_whiteListAddress[msg.sender];
    }

    function getMintedPerWallet() external view returns (uint256) {
        return s_mintedWallet[msg.sender];
    }

    function getMintedNFT(uint256 tokenId) external view returns (NFTdetails memory) {
        return s_mintedNFTs[tokenId];
    }

    function getMintedNftForTesting(uint256 tokenId) external returns (NFTdetails memory) {
        forTestingPurposeOnly = s_mintedNFTs[tokenId];
        return forTestingPurposeOnly;
    }

    function getMyNFTsForTesting(uint256 id) external returns (NFTdetails memory) {
        forTestingPurposeOnly = yourNFTs[id];
        return forTestingPurposeOnly;
    }

    function getListedNFTLength() public view returns (uint256) {
        return s_allListedNFTs.length;
    }

    function getMyNftLength() external view returns (uint256) {
        return yourNFTs.length;
    }
}

//Contract address:- 0x5f8B32aaF7a2ba3Bf2113af973B6A5bE0504730c

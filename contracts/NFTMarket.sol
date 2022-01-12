//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;//to track items sold

    address payable owner;
    uint256 listingPrice= 0.025 ether; //API of Matic is similar to ether's

    constructor(){
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable newOwner;
        uint256 price;
        bool sold;
    }
    //mapping to fetch market items by id
    mapping(uint256=>MarketItem) private idToMarketItem;

    event MArketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable newOwner,
        uint256 price,
        bool sold
        );
    //enable FE get listing price
    function getListingPrice() public view returns (uint256){
            return listingPrice;
    }
    //nonReentrant identifier is used to prevent reentrancy attacks
    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant{
        require(price>0, "Price must be at least 1 wei");
        require(msg.value== listingPrice, "Price must be equal than listing price");

        _itemIds.increment(); //first item id is 1
        uint256 itemId= _itemIds.current();

        idToMarketItem[itemId]= MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)), //nobody currently owns the item
            price,
            false
        );

        //transfer ownership of the item to the contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MArketItemCreated(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant{
        uint price= idToMarketItem[itemId].price;
        uint tokenId= idToMarketItem[itemId].tokenId; 

        require(msg.value == price, "Please submit the correct asking price");

        //transfer money to seller
        idToMarketItem[itemId].seller.transfer(msg.value);

        //transfer ownership of the item to the new Owner
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        //update the item struct
        idToMarketItem[itemId].newOwner= payable(msg.sender);
        idToMarketItem[itemId].sold= true;

        //increment number of items sold
        _itemsSold.increment();

        //pay the old owner (commissions)
        payable(owner).transfer(listingPrice);
    }

//returns unsold items
    function fetchMarketItems() public view returns(MarketItem[] memory){
      uint itemCount= _itemIds.current();
      uint unSoldItemCount=_itemIds.current()- _itemsSold.current();
      //looking for unsold items
      //only time idToMarketItem[itemId].owner is not payable(address(0)) is when the item is sold
    uint currentIndex= 0;
    MarketItem[] memory items= new MarketItem[](unSoldItemCount);
    for(uint i= 0; i< itemCount; i++){
        if(idToMarketItem[i+1].newOwner == address(0)){
            uint currentId= i+1;
            MarketItem storage currentItem= idToMarketItem[currentId];
            items[currentIndex]= currentItem;
            currentIndex+=1;
        }
    }
    return items;
    }

    //returns items purchased by the user
    function fetchMyNFTs() public view returns(MarketItem[] memory){
        uint totalItemCount= _itemIds.current();
        uint itemCount=0;
        uint currentIndex= 0;

        //get the number of items sold
        for(uint i=0; i< totalItemCount; i++){
            if(idToMarketItem[i+1].newOwner == msg.sender){
                itemCount+=1;
            }
        }
        //get list of items sold
        MarketItem[] memory items= new MarketItem[](itemCount);
        for(uint i= 0; i< totalItemCount; i++){
        if(idToMarketItem[i+1].newOwner == msg.sender){
            uint currentId= i+1;
            MarketItem storage currentItem= idToMarketItem[currentId];
            items[currentIndex]= currentItem;
            currentIndex+=1;
        }
    }
    return items;
    }

    //returns items created by the user
    function fetchItemsCreated() public view returns(MarketItem [] memory){
        uint totalItemCount= _itemIds.current();
        uint itemCount=0;
        uint currentIndex= 0;

        //get the number of items created
        for(uint i=0; i< totalItemCount; i++){
            if(idToMarketItem[i+1].seller == msg.sender){
                itemCount+=1;
            }
        }
        //get list of items created
        MarketItem[] memory items= new MarketItem[](itemCount);
        for(uint i= 0; i< totalItemCount; i++){
        if(idToMarketItem[i+1].seller == msg.sender){
            uint currentId= i+1;
            MarketItem storage currentItem= idToMarketItem[currentId];
            items[currentIndex]= currentItem;
            currentIndex+=1;
        }
    }
    return items;
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage{
    //create unique identifier for each token
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address marketPlaceAddress;

constructor(address _marketPlaceAddress) ERC721("Splash Tokens", "SPLT"){
    marketPlaceAddress = _marketPlaceAddress;
}

function createToken(string memory tokenURI) public returns(uint){
    //increment tokenId starting from 1
    _tokenIds.increment();
    //get current value to the tokenId
    uint256 newItemId = _tokenIds.current();
     //mint token to the owner
     _mint(msg.sender, newItemId);
     _setTokenURI(newItemId, tokenURI);
     //give marketplace approval to transact with token
     setApprovalForAll(marketPlaceAddress, true); 
     return newItemId;
}
}
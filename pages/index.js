import { ethers } from "ethers";
import { useState, useEffect } from "react";
import axios from "axios";
import Web3Modal from "web3modal";

import { nftAddress, nftMarketAddress } from "../config";
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import Market from "../artifacts/contracts/NFTMarket.sol/NFTMarket.json";

export default function Home() {
  const [nfts, setNfts] = useState([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    loadNfts();
  }, []);

  //call smart contract and fetch NFTs
  const loadNfts = async () => {
    const provider = new ethers.providers.JsonRpcProvider(
      "https://rpc-mumbai.matic.today"
    );
    const tokenContract = new ethers.Contract(nftAddress, NFT.abi, provider);
    const marketContract = new ethers.Contract(
      nftMarketAddress,
      Market.abi,
      provider
    );
    const data = await marketContract.fetchMarketItems();

    const items = await Promise.all(
      data.map(async (item) => {
        const tokenURI = await tokenContract.tokenURI(item.tokenId);
        //get token metadata
        const meta = await axios.get(tokenURI);
        let price = ethers.utils.formatUnits(item.price.toString(), "ether");
        let collection = {
          price,
          tokenId: item.tokenId,
          owner: item.newOwner,
          image: meta.data.image,
          name: meta.data.name,
          description: meta.data.description,
        };
        return collection;
      })
    );
    setNfts(items);
    setLoaded(true);
  };

  const buyNFT = async (nft) => {
    //allow user connect to their wallet
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(nftMarketAddress, Market.abi, signer);

    //get price of NFT
    const price = ethers.utils.parseUnits(nft.price.toString(), "ether");
    //create sale
    const transaction = await contract.createMarketSale(
      nftAddress,
      nft.tokenId,
      { value: price }
    );

    //wait for transaction to finish then reload page
    await transaction.wait();
    loadNfts();
  };
  if (loaded && nfts.length === 0) {
    return (
      <h1 className="px-20 py-10 text-3xl text-center">
        No items in the marketplace
      </h1>
    );
  }
  if (!loaded) {
    return <h1 className="px-20 py-10 text-3xl text-center">Loading...</h1>;
  }
  return (
    <div className="flex justify-center">
      <div className="px-4" style={{ maxWidth: "1600px" }}>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {nfts.map((nft, i) => (
            <div key={i} className="border shadow rounded-xl overflow-hidden">
              <img src={nft.image} alt={nft.name} />
              <div className="p-4">
                <p
                  style={{ height: "64px" }}
                  className="text-2xl font-semibold"
                >
                  {nft.name}
                </p>
                <div style={{ height: "70px", overflow: "hidden" }}>
                  <p className="text-gray-600 text-sm">{nft.description}</p>
                </div>
              </div>
              <div className="p-4 bg-black">
                <p className="text-2xl mb-4 font-bold text-white">
                  {nft.price} Matic
                </p>
                <button
                  className="w-full bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-12 "
                  onClick={() => buyNFT(nft)}
                >
                  Buy
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

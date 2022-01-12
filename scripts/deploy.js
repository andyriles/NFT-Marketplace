const hre = require("hardhat");

async function main() {
  const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
  const nftMarket = await NFTMarket.deploy();
  await nftMarket.deployed();
  //console.log("nftMarket deployed to:", nftMarket.address);
  //bug in mumbai testnet
  const txHash1 = nftMarket.deployTransaction.hash;
  console.log(`Tx hash: ${txHash1}\nWaiting for transaction to be mined...`);
  const txReceipt1 = await ethers.provider.waitForTransaction(txHash1);

  console.log("nftMarket deployed to:", txReceipt1.contractAddress);

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(txReceipt1.contractAddress);
  await nft.deployed();
  //bug in mumbai testnet
  const txHash = nft.deployTransaction.hash;
  console.log(`Tx hash: ${txHash}\nWaiting for transaction to be mined...`);
  const txReceipt = await ethers.provider.waitForTransaction(txHash);

  console.log("nft deployed to:", txReceipt.contractAddress);

  //console.log("nft deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

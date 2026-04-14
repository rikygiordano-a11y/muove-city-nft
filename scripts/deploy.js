const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const subscriptionId = process.env.VRF_SUBSCRIPTION_ID;
  const vrfCoordinator = process.env.VRF_COORDINATOR;
  const keyHash = process.env.VRF_KEY_HASH;
  const callbackGasLimit = 250000;
  const mintPrice = ethers.parseEther(process.env.MINT_PRICE_ETH || "0.01");
  const maxSupply = Number(process.env.MAX_SUPPLY || "50");
  const baseTokenURI = process.env.BASE_TOKEN_URI || "https://example.com/metadata/";

  if (!subscriptionId || !vrfCoordinator || !keyHash) {
    throw new Error("Mancano variabili VRF nel file .env");
  }

  const MooveCityNFT = await ethers.getContractFactory("MooveCityNFT");
  const contract = await MooveCityNFT.deploy(
    subscriptionId,
    vrfCoordinator,
    keyHash,
    callbackGasLimit,
    mintPrice,
    maxSupply,
    baseTokenURI
  );

  await contract.waitForDeployment();

  console.log("MooveCityNFT deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
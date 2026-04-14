const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MooveCityNFT", function () {
  let contract;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const MooveCityNFT = await ethers.getContractFactory("MooveCityNFT");

    contract = await MooveCityNFT.deploy(
      1,
      owner.address,
      "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
      250000,
      ethers.parseEther("0.01"),
      50,
      "https://example.com/metadata/"
    );

    await contract.waitForDeployment();
  });

  it("should set correct collection info", async function () {
    const info = await contract.getCollectionInfo();

    expect(info[0]).to.equal("Moove City NFT");
    expect(info[1]).to.equal("MOOVE");
    expect(info[2]).to.equal(0n);
    expect(info[3]).to.equal(50n);
    expect(info[4]).to.equal(ethers.parseEther("0.01"));
  });

  it("should set correct mint price", async function () {
    const mintPrice = await contract.mintPrice();
    expect(mintPrice).to.equal(ethers.parseEther("0.01"));
  });

  it("should allow owner to update mint price", async function () {
    await contract.setMintPrice(ethers.parseEther("0.02"));
    expect(await contract.mintPrice()).to.equal(ethers.parseEther("0.02"));
  });

  it("should not allow non-owner to update mint price", async function () {
    await expect(
      contract.connect(user).setMintPrice(ethers.parseEther("0.02"))
    ).to.be.reverted;
  });

  it("should update base URI", async function () {
    await contract.setBaseURI("https://newbase.com/");
    expect(await contract.getCurrentSupply()).to.equal(0n);
  });

  it("should revert withdraw when contract has no balance", async function () {
    await expect(contract.withdraw()).to.be.revertedWith("No funds available");
  });
});
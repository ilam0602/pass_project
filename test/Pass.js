const { expect } = require("chai");
const hre = require("hardhat");

describe("Token contract", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const [owner] = await ethers.getSigners();

    const passContract = await ethers.deployContract("Pass");

    const amount = 100; // Replace with your actual value
    const saleStartTime =(await ethers.provider.getBlock("latest")).timestamp + 60;
  
    const _price= hre.ethers.parseEther((1.5 * .001).toString()); // 1 ETH = 1e18 Wei 
    const data = "0x"; // Replace with your actual value
  
    // Call the mintPass function with the arguments
    await passContract.mintPass(amount, saleStartTime, _price, data); 
    const ownerBalance = await passContract.balanceOf(owner.address,0);
    expect(amount).to.equal(ownerBalance);

  });
});
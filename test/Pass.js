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
  it("Price should update correctly after minting a certain amount", async function () {
    const [owner,signer1,signer2] = await ethers.getSigners();

    const passContract = await ethers.deployContract("Pass");
    const prevCol = await ethers.deployContract("PrevCol", [owner.address]);

    const amount = 100; // Replace with your actual value
    const saleStartTime =(await ethers.provider.getBlock("latest")).timestamp + 60;
    const _price= hre.ethers.parseEther((1.5 * .001).toString()); // 1 ETH = 1e18 Wei 
    const data = "0x"; // Replace with your actual value
    await passContract.mintPass(amount, saleStartTime, _price, data); 
  
    await hre.network.provider.send("evm_increaseTime", [60]);
    await hre.network.provider.send("evm_mine"); // This mines a new block 
  
    // Call the mintPass function with the arguments
    await passContract.setPreviousCollectionAddress(prevCol.target);
    await prevCol.safeMint(signer1.address);
    const ownerBalance = await passContract.balanceOf(owner.address,0);
    expect(amount).to.equal(ownerBalance);
    const currPrice =(await passContract.getPassPrice(0,1)).toString();
    console.log("price: ",currPrice);

    await passContract.connect(signer1).purchasePass(0,1, {value:currPrice.toString()});
  })

});
const { expect } = require("chai");
const hre = require("hardhat");

describe("Token contract", function () {
  let owner, signer1, signer2;
  let passContract, prevCol;
  let amount, saleStartTime, _price, data, priceInc;

  // This will run before each test
  beforeEach(async function () {
    [owner, signer1, signer2] = await ethers.getSigners();
    passContract = await ethers.deployContract("Pass");
    prevCol = await ethers.deployContract("PrevCol", [owner.address]);

    amount = 100; // Replace with your actual value
    saleStartTime = (await ethers.provider.getBlock("latest")).timestamp + 60;
    _price = hre.ethers.parseEther((1.5 * .001).toString()); // 1 ETH = 1e18 Wei 
    data = "0x"; // Replace with your actual value
    priceInc = hre.ethers.parseEther((.5 * .001).toString());
  });

  it("Deployment should assign the total supply of tokens to the owner", async function () {
    // Test-specific code here
    await passContract.mintPass(amount, saleStartTime, _price, data);
    const ownerBalance = await passContract.balanceOf(owner.address, 0);
    expect(amount).to.equal(ownerBalance);
  });

  it("Price should update correctly after minting a certain amount", async function () {
    // Test-specific code here
    await passContract.mintPass(amount, saleStartTime, _price, data);

    await hre.network.provider.send("evm_increaseTime", [60]);
    await hre.network.provider.send("evm_mine");

    await passContract.setPreviousCollectionAddress(prevCol.target);
    await prevCol.safeMint(signer1.address);
    const ownerBalance = await passContract.balanceOf(owner.address, 0);
    expect(amount).to.equal(ownerBalance);
    const p0=v0 =(await passContract.getPassPrice(0,1));
    console.log("p0 (after minting 0): ",p0);

    await passContract.connect(signer1).purchasePass(0,1, {value:v0.toString()});
    const p1 =(await passContract.getPassPrice(0,1));
    expect(p1).to.equal(p0);
    console.log("p1(after minting 1): ",p1);

    const v1 = (await passContract.getPassPrice(0,4));
    await passContract.connect(signer1).purchasePass(0,4, {value:v1.toString()});


    const p5 = (await passContract.getPassPrice(0,1));
    expect(p5).to.equal(p1+ priceInc);
    console.log("p5: ",p5);

    const v2 = (await passContract.getPassPrice(0,5));
    await passContract.connect(signer1).purchasePass(0,5, {value:v2.toString()});

    const p10 = (await passContract.getPassPrice(0,1));
    expect(p10).to.equal(p5+ priceInc);
    console.log("p10:",p10);

    const v3 = (await passContract.getPassPrice(0,10));
    await passContract.connect(signer1).purchasePass(0,10, {value:v3.toString()});

    const p20 = (await passContract.getPassPrice(0,1));
    expect(p20).to.equal(p10+ priceInc*BigInt(2));
    console.log("p20:",p20);


    const v4 = (await passContract.getPassPrice(0,7));
    await passContract.connect(signer1).purchasePass(0,7, {value:v4.toString()});
    

    const p27 = (await passContract.getPassPrice(0,1));
    expect(p27).to.equal(p20+ priceInc);
    console.log("p27:",p27);

    const v5 = (await passContract.getPassPrice(0,3));
    await passContract.connect(signer1).purchasePass(0,3, {value:v5.toString()});
    
    const p30 = (await passContract.getPassPrice(0,1));
    expect(p30).to.equal(p27+ priceInc);
    console.log("p30:",p30);
  })
  it("Price should update correctly after minting a certain amount part 2", async function () {
    // Test-specific code here
    await passContract.mintPass(amount, saleStartTime, _price, data);

    await hre.network.provider.send("evm_increaseTime", [60]);
    await hre.network.provider.send("evm_mine");

    await passContract.setPreviousCollectionAddress(prevCol.target);
    await prevCol.safeMint(signer1.address);
    const ownerBalance = await passContract.balanceOf(owner.address, 0);
    expect(amount).to.equal(ownerBalance);
    const p0 =(await passContract.getPassPrice(0,1));

    console.log("p0 (after minting 0): ",p0);

    const v6 = (await passContract.getPassPrice(0,6));

    await passContract.connect(signer1).purchasePass(0,6, {value:v6.toString()});
    const p7 =(await passContract.getPassPrice(0,1));
    expect(p7).to.equal(p0 + priceInc);

    const v9 = (await passContract.getPassPrice(0,3));
    await passContract.connect(signer1).purchasePass(0,3, {value:v9.toString()});


    const p10 = (await passContract.getPassPrice(0,1));
    expect(p10).to.equal(p7);

    const v11 = (await passContract.getPassPrice(0,2));
    await passContract.connect(signer1).purchasePass(0,2, {value:v11.toString()});

    const p12 = (await passContract.getPassPrice(0,1));
    expect(p12).to.equal(p10+ priceInc);

    const v15 = (await passContract.getPassPrice(0,4));
    await passContract.connect(signer1).purchasePass(0,4, {value:v15.toString()});

    const p16 = (await passContract.getPassPrice(0,1));
    expect(p16).to.equal(p12+ priceInc);


    const v18 = (await passContract.getPassPrice(0,3));
    await passContract.connect(signer1).purchasePass(0,3, {value:v18.toString()});
    console.log("v18: ",v18);
    

    const p19 = (await passContract.getPassPrice(0,1));
    expect(p19).to.equal(p16);

    const v21 = (await passContract.getPassPrice(0,3));
    await passContract.connect(signer1).purchasePass(0,3, {value:v21.toString()});
    console.log("v21: ",v21);
    
    const p22 = (await passContract.getPassPrice(0,1));
    expect(p22).to.equal(p19+ priceInc);
  })

});
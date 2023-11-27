import { ethers } from "hardhat";

import {BigNumberish,BytesLike,parseEther} from "ethers";

async function main() {
  const pass = await ethers.deployContract("Pass");

  await pass.waitForDeployment();

  console.log(
    `deployed to ${pass.target}`
  );

   // Define dummy variables for the function arguments
   const amount: BigNumberish = 100; // Replace with your actual value
   const saleStartTime: BigNumberish =(await ethers.provider.getBlock("latest")).timestamp + 60;
 
   const _price: BigNumberish = parseEther((1.5 * .001).toString()); // 1 ETH = 1e18 Wei 
   const data: BytesLike = "0x"; // Replace with your actual value
 
   // Call the mintPass function with the arguments
   await pass.mintPass(amount, saleStartTime, _price, data); 
   await pass.setPreviousCollectionAddress("0xEf861b08F9b013F1642D93d3A344C5426F8a5e14");

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

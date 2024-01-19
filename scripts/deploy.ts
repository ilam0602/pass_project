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
   const saleStartTime: BigNumberish = (await ethers.provider.getBlock("latest")).timestamp + 60;
  //  const saleStartTime: BigNumberish = 	1705733339;
 
   const _price: BigNumberish = parseEther((1.5 * .001).toString()); // 1 ETH = 1e18 Wei 
   const data: BytesLike = "0x"; // Replace with your actual value

   //on mainnet
  //  const FiHPAddress : string = "0x92D89652181901D3292Ba4d8ff423eA18373ce7c";
  //  const devWallet : string = "0xAf5Aa6556c73442e69156b825Fd3702d3778a7eF";
  //  const ownerWallet : string = "friendsinhighplaces.eth";
 
   // Call the mintPass function with the arguments
   await pass.mintPass(amount, saleStartTime, _price, data); 
   await pass.setPreviousCollectionAddress("0x0fA2a65C581C9618A33f43bca37179dc28619F0c");
   await pass.setDevWallet("0x2fB590D0b71F3665b26388238CAa718d7f3Cc57d");
   await pass.setOwnerWallet("0x0fA2a65C581C9618A33f43bca37179dc28619F0c");

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

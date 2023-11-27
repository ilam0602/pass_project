import { ethers } from "hardhat";

import {BigNumberish,BytesLike,parseEther} from "ethers";

async function main() {
  const pass = await ethers.deployContract("PrevCol",["0xBB923B99A0067e8ae37533898B849d67B8f3268e"]);

  await pass.waitForDeployment();

  console.log(
    `deployed to ${pass.target}`
  );

 
  //  Call the mintPass function with the arguments
   await pass.safeMint("0xBB923B99A0067e8ae37533898B849d67B8f3268e"); 
   await pass.safeMint("0x2fB590D0b71F3665b26388238CAa718d7f3Cc57d"); 

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

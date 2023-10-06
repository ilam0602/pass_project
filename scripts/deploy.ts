import { ethers } from "hardhat";

async function main() {
  const pass = await ethers.deployContract("Pass");

  await pass.waitForDeployment();

  console.log(
    `deployed to ${pass.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

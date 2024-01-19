import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

// Load .env variables
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      chainId: 31337 // default chain ID for Hardhat
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ''],
      // gasPrice: 15000000000 //15gwei
    },
    mainnet: {
      url:`https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_MAIN_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY_MAIN || ''],
      // gasPrice: 15000000000 //15gwei
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};

export default config;

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
   networks: {
    hardhat: {
      chainId: 1337,
    },
    scrollSepolia: {
      url: process.env.SCROLL_RPC_URL,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY!],
    },
  },
  
  etherscan: {
    apiKey:{
      // arbitrumSepolia: "11XBITUSRTETURM7D2JTXPE49ZG84GPMX7",
    }
  },
};








export default config;

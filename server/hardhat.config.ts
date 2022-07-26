import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  defaultNetwork: "hardhat",
  networks: {
    rinkeby: {
      chainId: 4,
      accounts: [process.env.RINKBEY_ACC!],
      url: process.env.RINKBEY_URL,
    }
  },
  namedAccounts: {
    deployer: {
      default: 1
    }
  }
};

export default config;

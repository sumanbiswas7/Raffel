import { network } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";
import { devChains } from "../hardhat.helper.config";

const deployFunction: DeployFunction = async ({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const BASE_FEE = "250000000000000000"; // 0.25 is this the premium in LINK?
    const GAS_PRICE_LINK = 1e9; // link per gas, is this the gas lane? // 0.000000001 LINK per gas

    if (devChains.includes(network.name)) {
        console.log("::::: Deploying Mocks ...")
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            args: [BASE_FEE, GAS_PRICE_LINK],
            log: true
        })
        console.log("-:-:-:-:-: Deploy Sucessfull :-:-:-:-:-")
    }
}


export default deployFunction;
deployFunction.tags = ["all", "mocks"];
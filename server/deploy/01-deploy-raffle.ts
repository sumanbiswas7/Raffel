import { network, ethers } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types"
import { devChains, networkConfig } from "../hardhat.helper.config";


const deployFunction: DeployFunction = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const config = networkConfig[chainId as keyof typeof networkConfig];
  let vrfCoordinator, subcriptionId;
  console.log("::::: Deploying Raffle ...")

  if (devChains.includes(network.name)) {
    const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock");
    const transactionResponse = await vrfCoordinatorV2Mock.createSubscription();
    const transactionReceipt = await transactionResponse.wait();

    vrfCoordinator = vrfCoordinatorV2Mock.address;
    subcriptionId = transactionReceipt.events[0].args.subId;
  } else {
    vrfCoordinator = config["vrfCoordinator" as keyof typeof config]
  }

  const gasLane = config["gasLane" as keyof typeof config];
  const callbackGasLimit = config["callbackGasLimit" as keyof typeof config];
  const interval = config["interval" as keyof typeof config];
  const entranceFee = config["entranceFee" as keyof typeof config];

  await deploy("Raffle", {
    from: deployer,
    args: [subcriptionId, vrfCoordinator, gasLane, callbackGasLimit, interval, entranceFee],
    log: true
  })

  console.log("-:-:-:-:-: Deploy Sucessfull :-:-:-:-:-")
}

export default deployFunction;
deployFunction.tags = ["all", "raffle"];
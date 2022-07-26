const networkConfig = {
    31337: {
        name: "hardhat",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        interval: "30",
        entranceFee: "100000000000000000", // 0.1 ETH
        callbackGasLimit: "500000",
    }, 4: {
        name: "rinkeby",
        subcriptionId: "9003",
        vrfCoordinator: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        interval: "30",
        entranceFee: "100000000000000000", // 0.1 ETH
        callbackGasLimit: "500000",
    }
}

const devChains = ["localhost", "hardhat"]


export { networkConfig, devChains }
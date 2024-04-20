const hre = require("hardhat");

async function main() {
    const Lock = await hre.ethers.getContractFactory("Lock");
    const lock = await Lock.deploy();
    await lock.deployed();

    console.log(`Contract deployed at address ${lock.getAddress()}`);

}

main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
})
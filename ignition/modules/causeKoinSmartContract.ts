import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "";
const nftAddress = "";

const CauseKoinSmartContractModule = buildModule("CauseKoinSmartContractModule", (m) => {

    const save = m.contract("CauseKoinSmartContract", [tokenAddress,nftAddress]);

    return { save };
});

export default CauseKoinSmartContractModule;

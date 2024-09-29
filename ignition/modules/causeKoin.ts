import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CauseKoinModule = buildModule("CauseKoinModule", (m) => {

    const erc20 = m.contract("CauseKoin");

    return { erc20 };
});

export default CauseKoinModule;

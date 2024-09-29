import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x4A5097c697397E6b790A7f8B59EB9CE556A1D6D4";
const nftAddress = "0x2d6829Bd5e2635aFf778DA6FC3891CAB5C1145D0";

const ContributionRewardSystemModule = buildModule("ContributionRewardSystemModule", (m) => {

    const save = m.contract("ContributionRewardSystem", [tokenAddress,nftAddress]);

    return { save };
});

export default ContributionRewardSystemModule;

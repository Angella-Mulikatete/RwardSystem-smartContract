import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MyNFTModule = buildModule("MyNFTModule", (m) => {

    const nft = m.contract("PlasticContributionNFT");

    return { nft };
});



export default MyNFTModule;

import { ethers } from "https://cdnjs.cloudflare.com/ajax/libs/ethers/6.7.0/ethers.min.js";

export async function createMilestone(contract, desc, ethAmount, vendorAddr) {
    const wei = ethers.parseEther(ethAmount);
    const tx = await contract.addMilestone(desc, wei, vendorAddr);
    return await tx.wait();
}

export async function releaseHalf(contract, id) {
    const tx = await contract.releaseInitial50Percent(id);
    return await tx.wait();
}

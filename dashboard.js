export async function getMilestoneData(contract, id) {
    return await contract.milestones(id);
}

export async function getContractBalance(contract) {
    return await contract.getBalance();
}